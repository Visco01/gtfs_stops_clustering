#!/usr/bin/env ruby
# lib/gtfs_stops_clustering.rb
require 'rubygems'
require 'bundler/setup'
require 'gtfs'
require 'csv'
require_relative './gtfs_stops_clustering/data_import'
require_relative './gtfs_stops_clustering/dbscan'

module GtfsStopsClustering
  VERSION='0.0.1'
  attr_accessor :gtfs_stops_clustering

  class GtfsStopsClustering
    attr_accessor :clusters, :gtfs_urls, :gtfs_stops, :stops_config_path, :epsilon, :min_points, :names_similarity

    def initialize(gtfs_urls, epsilon, min_points, names_similarity, stops_config_path)
      @clusters = []
      unless gtfs_urls.empty?
        @gtfs_paths = gtfs_urls
        @stops_config_path = stops_config_path
        @epsilon = epsilon
        @min_points = min_points
        @names_similarity = names_similarity
        @gtfs_stops = create_stops_merged
        clusterize_stops_csv(@gtfs_stops)
      end
    end

    def create_stops_merged
      gtfs_stops = []
      @gtfs_paths.each do |gtfs_path|
        gtfs = GTFS::Source.build(gtfs_path)
        gtfs_stops << gtfs.stops
      end
      gtfs_stops.flatten
    end

    def clusterize_stops_csv(stops_merged)
      data = import_stops_data(stops_merged, @stops_config_path)
      @clusters = DBSCAN( data[:stops_data], data[:stops_redis_geodata], :epsilon => @epsilon, :min_points => @min_points, :similarity => @names_similarity, :distance => :haversine_distance2, :labels => data[:stops_names] )

      @clusters.each do |cluster_id, cluster|
        cluster.each do |stop|
          gtfs_stop = @gtfs_stops.find { |e| e.lat == stop[:stop_lat] && e.lon == stop[:stop_lon] }
          stop[:stop_id] = gtfs_stop.id
          stop[:stop_code] = gtfs_stop.code
          stop[:parent_station] = gtfs_stop.parent_station
        end
      end

      output_path = 'stop_clusters.txt'
      File.open(output_path, 'w') do |file|
        @clusters.each do |cluster_id, cluster |
          file.puts "Cluster #{cluster_id}"
          cluster.each do |point|
            file.puts point.inspect
          end
          file.puts
        end
      end
    end
  end

  def build(gtfs_urls, epsilon, min_points, names_similarity = 1, stop_config_path = '')
    @gtfs_stops_clustering = GtfsStopsClustering.new(gtfs_urls, epsilon, min_points, names_similarity, stop_config_path)
    @gtfs_stops_clustering.clusters
  end
end

include GtfsStopsClustering
