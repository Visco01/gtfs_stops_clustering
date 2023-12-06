require 'minitest/autorun'
require_relative '../lib/gtfs_stops_clustering'

class GtfsStopClustersTest < Minitest::Test
  def test_gtfs_stop_clusters_success
    gtfs_urls = ['https://developers.google.com/static/transit/gtfs/examples/sample-feed.zip']

    clusters = GtfsStopsClustering.build(gtfs_urls, 0.3, 1, 0.85, 'path/to/stop_config.txt')

    assert_instance_of Hash, clusters
    clusters.each do |cluster_id, cluster|
      assert_instance_of Array, cluster
      cluster.each do |stop|
        assert_instance_of Hash, stop
      end
    end
  end
end
