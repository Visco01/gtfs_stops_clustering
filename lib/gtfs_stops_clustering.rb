# frozen_string_literal: true

# lib/gtfs_stops_clustering.rb

require "rubygems"
require "bundler/setup"
require_relative "gtfs_stops_clustering/version"
require "gtfs"
require "csv"
require_relative "./gtfs_stops_clustering/data_import"
require_relative "./gtfs_stops_clustering/dbscan"
require_relative "./gtfs_stops_clustering/input_consistency_checks"

# GtfsStopClustering module
module GtfsStopsClustering
  attr_accessor :gtfs_stops_clustering

  # GtfsStopsClustering class
  class GtfsStopsClustering
    include InputConsistencyChecks
    include DataImport
    include DBSCAN
    attr_accessor :clusters, :gtfs_paths, :gtfs_stops, :stops_config_path, :epsilon, :min_points, :names_similarity

    def initialize(gtfs_paths, epsilon, min_points, names_similarity, stops_config_path)
      @gtfs_paths = gtfs_paths
      @stops_config_path = stops_config_path
      @epsilon = epsilon
      @min_points = min_points
      @names_similarity = names_similarity
      input_consistency_checks(@gtfs_paths, @epsilon, @min_points, @names_similarity, @stops_config_path)
      @clusters = []
      @gtfs_stops = create_stops_merged
      clusterize_stops
    end

    def create_stops_merged
      gtfs_stops = []
      @gtfs_paths.each do |gtfs_path|
        gtfs = GTFS::Source.build(gtfs_path)
        gtfs_stops << gtfs.stops
      end
      gtfs_stops.flatten
    end

    def clusterize_stops
      data = import_stops_data(@gtfs_stops, @stops_config_path)
      @clusters = DBSCAN(data[:stops_data],
                         data[:stops_redis_geodata],
                         epsilon: @epsilon,
                         min_points: @min_points,
                         similarity: @names_similarity,
                         distance: :haversine_distance2,
                         labels: data[:stops_names])
      map_clustered_stops
    end

    def map_clustered_stops
      @clusters.each_value do |cluster|
        cluster.each do |stop|
          gtfs_stop = @gtfs_stops.find { |e| e.lat == stop[:stop_lat] && e.lon == stop[:stop_lon] }
          stop[:stop_id] = gtfs_stop.id
          stop[:stop_code] = gtfs_stop.code
          stop[:parent_station] = gtfs_stop.parent_station
        end
      end
    end
  end

  def build_clusters(gtfs_paths, epsilon, min_points, names_similarity = 1, stop_config_path = "")
    @gtfs_stops_clustering = GtfsStopsClustering.new(gtfs_paths, epsilon, min_points, names_similarity, stop_config_path)
    @gtfs_stops_clustering.clusters
  end
end
