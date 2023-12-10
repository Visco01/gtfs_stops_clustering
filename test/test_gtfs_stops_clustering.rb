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

    assert_correct_clusters(clusters)
  end

  def assert_correct_clusters(clusters)
    stops_not_clustered = clusters[-1]
    assert_correct_cluster(stops_not_clustered, nil, 4)

    first_cluster = clusters[0]
    assert_correct_cluster(first_cluster, "Awesome Stop Name", 2)

    second_cluster = clusters[1]
    assert_correct_cluster(second_cluster, "Nye County Airport", 3)
  end

  def assert_correct_cluster(cluster, cluster_name, cluster_size)
    assert !cluster.nil?
    assert_equal cluster_size, cluster.length
    cluster.each do |stop|
      assert_equal cluster_name, stop[:cluster_name]
    end
  end

  def test_gtfs_file_not_found
    gtfs_paths = ["/invalid/path/.zip"]

    assert_raises StandardError do
      build_clusters(gtfs_paths, 0.3, 1, 0.85)
    end
  end
end
