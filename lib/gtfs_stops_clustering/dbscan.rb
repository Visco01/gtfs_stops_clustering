# frozen_string_literal: true

# lib/gtfs_stops_clustering/dbscan.rb

require "distance_measures"
require "text"
require "geocoder"
require_relative "redis_geodata"

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
          point.cluster = current_cluster
          cluster = [point].push(add_connected(neighbors, current_cluster))
          clusters[current_cluster] = cluster.flatten

          # Get Cluster Name
          labels = clusters[current_cluster].map { |e| e.label.capitalize }
          cluster_name = find_cluster_name(labels)

          # Get Cluster Position
          cluster_pos = find_cluster_position(clusters[current_cluster])

          clusters[current_cluster].each do |e|
            e.cluster_name = cluster_name
            e.cluster_pos = cluster_pos
          end
        else
          clusters[-1].push(point)
        end
      end
    end

    def results
      hash = {}
      @clusters.dup.each { |cluster_index, value| hash[cluster_index] = value.flatten.map(&:items) unless value.flatten.empty? }
      hash
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
        coordinates = neighbor_pos.split(",")
        neighbor = @points.find do |elem|
          elem.items[0] == coordinates[1] &&
            elem.items[1] == coordinates[0]
        end
        next unless neighbor

        string_distance = Text::Levenshtein.distance(point.label.downcase, neighbor.label.downcase)
        similarity = 1 - string_distance.to_f / [point.label.length, point.label.length].max
        neighbors.push(neighbor) if similarity > options[:similarity]
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

    def find_cluster_name(labels)
      words = labels.map { |label| label.strip.split }
      common_title = ""

      # Loop through each word index starting from the first
      (0...words.first.length).each do |i|
        words_at_index = words.map { |word_list| word_list[i] }

        break unless words_at_index.uniq.length == 1

        common_title += " #{words_at_index.first.capitalize}"
      end

      common_title.strip ? common_title : labels.first
    end
    def find_cluster_position(cluster)
      total_lat = cluster.map { |e| e.items[0].to_f }.sum
      total_lon = cluster.map { |e| e.items[1].to_f }.sum
      avg_lat = total_lat / cluster.size
      avg_lon = total_lon / cluster.size
      [avg_lat, avg_lon]
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

  def DBSCAN(* args)
    clusterer = Clusterer.new(*args)
    clusterer.labeled_results
  end
end
