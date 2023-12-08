# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/gtfs_stops_clustering"

# ConsistencyChecksTest class
class ConsistencyChecksTest < Minitest::Test
  include GtfsStopsClustering

  def test_gtfs_paths_nil
    gtfs_urls = nil

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, 1, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_gtfs_paths_not_array
    gtfs_urls = "https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, 1, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_gtfs_paths_empty
    gtfs_urls = []

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, 1, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_epsilon_not_float
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    epsilon = "0.3"

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, epsilon, 1, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_epsilon_negative
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    epsilon = -0.3

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, epsilon, 1, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_min_points_not_integer
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    min_points = "1"

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, min_points, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_min_points_negative
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    min_points = -1

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, min_points, 0.85, "path/to/stop_config.txt")
    end
  end

  def test_names_similarity_not_float
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    names_similarity = "0.85"

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, 1, names_similarity, "path/to/stop_config.txt")
    end
  end

  def test_names_similarity_negative
    gtfs_urls = ["https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip"]
    names_similarity = -0.85

    assert_raises ArgumentError do
      build_clusters(gtfs_urls, 0.3, 1, names_similarity, "path/to/stop_config.txt")
    end
  end
end
