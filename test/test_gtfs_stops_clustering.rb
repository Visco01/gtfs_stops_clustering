# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/gtfs_stops_clustering"

# Main Test class
class GtfsStopClustersTest < Minitest::Test
  include GtfsStopsClustering

  def test_gtfs_stop_clusters_success
    gtfs_paths = ["test/fixtures/sample-feed.zip"]

    clusters = build_clusters(gtfs_paths, 0.3, 1, 0.85)

    assert_instance_of Hash, clusters
    clusters.each_value do |cluster|
      assert_instance_of Array, cluster
      cluster.each do |stop|
        assert_instance_of Hash, stop
      end
    end
  end

  def test_correct_clustering
    gtfs_paths = ["test/fixtures/sample-feed-2.zip"]
    stops_config_file = "test/fixtures/stops_config_sample.txt"

    clusters = build_clusters(gtfs_paths, 0.3, 1, 0.85, stops_config_file)

    assert_instance_of Hash, clusters
    clusters.each_value do |cluster|
      assert_instance_of Array, cluster
      cluster.each do |stop|
        assert_instance_of Hash, stop
      end
    end

    stops_not_clustered = clusters[-1]
    assert !stops_not_clustered.nil?
    assert_equal 4, stops_not_clustered.length

    first_cluster = clusters[0]
    assert !first_cluster.nil?
    assert_equal 2, first_cluster.length

    second_cluster = clusters[1]
    assert !second_cluster.nil?
    assert_equal 3, second_cluster.length
  end
end
