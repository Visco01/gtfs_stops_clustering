# lib/gtfs_stops_clustering/dbscan.rb

require "distance_measures"
require "text"
require "geocoder"
require_relative "redis_geodata"
require_relative "utils"

# Array class
class Array
  def haversine_distance2(other)
    Geocoder::Calculations.distance_between(self, other)
  end
end

# DBSCAN module
module DBSCAN
  # Clusterer class
  class Clusterer
    include RedisGeodata
    attr_accessor :points, :options, :clusters

    def initialize(points, stops_redis_geodata, options = {})
      options[:distance] = :euclidean_distance unless options[:distance]
      options[:labels] = [] unless options[:labels]

      redis_geodata_import(stops_redis_geodata, options[:epsilon])
      @options = options
      init_points(points)
      @clusters = { -1 => [] }

      clusterize!
    end

    def init_points(points)
      c = 0
      @points = points.map do |e|
        po = Point.new(e, @options[:labels][c])
        c += 1
        po
      end
    end

    def clusterize!
      current_cluster = -1
      @points.each do |point|
        next if point.visited?

        point.visit!
        neighbors = inmediate_neighbors(point)

        if neighbors.size >= options[:min_points]
          current_cluster += 1
          create_cluster(current_cluster, point, neighbors)
          update_cluster_info(current_cluster)
        else
          clusters[-1].push(point)
        end
      end
    end

    def create_cluster(cluster_index, point, neighbors)
      point.cluster = cluster_index
      cluster = [point].push(add_connected(neighbors, cluster_index))
      @clusters[cluster_index] = cluster.flatten
    end

    def update_cluster_info(cluster_index)
      labels = @clusters[cluster_index].map { |e| e.label.capitalize }
      @clusters[cluster_index].each do |e|
        e.cluster_name = Utils.find_cluster_name(labels)
        e.cluster_pos = Utils.find_cluster_position(clusters[cluster_index])
      end
    end

    def labeled_results
      hash = {}
      @clusters.each do |cluster_index, elements|
        hash.store(cluster_index, [])
        elements.each do |e|
          hash[cluster_index].push(
            {
              stop_id: nil,
              stop_code: nil,
              cluster_name: e.cluster_name,
              cluster_pos: e.cluster_pos,
              stop_name: e.label,
              stop_lat: e.items[0],
              stop_lon: e.items[1],
              parent_station: nil
            }
          )
        end
      end
      hash
    end

    def inmediate_neighbors(point)
      neighbors = []
      geosearch_results = geosearch(point.items[1], point.items[0])
      geosearch_results.each do |neighbor_pos|
        neighbor = Utils.find_inmediate_neighbor(neighbor_pos, @points)
        next unless neighbor

        neighbors.push(neighbor) if Utils.string_similarity(point.label.downcase, neighbor.label.downcase) > options[:similarity]
      end
      neighbors
    end

    def add_connected(neighbors, current_cluster)
      cluster_points = []
      neighbors.each do |point|
        unless point.visited?
          point.visit!
          new_points = inmediate_neighbors(point)

          if new_points.size >= options[:min_points]
            new_points.each do |p|
              neighbors.push(p) unless neighbors.include?(p)
            end
          end
        end

        unless point.cluster
          cluster_points.push(point)
          point.cluster = current_cluster
        end
      end

      cluster_points
    end
  end

  # Point class
  class Point
    attr_accessor :items, :cluster, :visited, :label, :cluster_name, :cluster_pos

    define_method(:visited?) { @visited }
    define_method(:visit!) { @visited = true }
    def initialize(point, label)
      @items,
      @cluster,
      @visited,
      @label = point,
      nil,
      false,
      label,
      @cluster_name,
      @cluster_pos = []
    end
  end

  def dbscan(* args)
    clusterer = Clusterer.new(*args)
    clusterer.labeled_results
  end
end
