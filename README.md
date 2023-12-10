# GTFS Stops clustering

GTFS Stops Clustering is a Ruby Gem designed to read [GTFS](https://gtfs.org) (General Transit Feed Specification) stops data and create clusters based on the following parameters:

- `GTFS paths` [Required]: array of gtfs zip files paths whose stops will be combined in the clustering algorithm
- `Epsilon` [Required]: the maximum distance (in km) between 2 stops for them to be considered neighbors of one another (e.g.: 0.01, 0.5, 2 etc.)
- `Min Points` [Required]: the minimum number of neighbors a point needs to have to be considered a core point (e.g.: 3, 5, 10 etc.)
- `Names Similarity` [Optional]: Besides geographical proximity, the algorithm also considers the similarity between stop names using techniques like string similarity measures. This enhances the clustering by including stops with similar names within the same cluster (e.g.: all values between 0 and 1. The more the value is in proximity of 1, the more similar the stop names need to be considered points of the same cluster). The default value is 1, so if you want to create clusters based only on stop positions, leave this to 0.
- `Stop config file` (CSV file path) [Optional]: This file is specifically designed to handle certain cases where stop names need to be altered or mapped to different names before running the clustering algorithm. Each entry consists of two columns:
**stop_name**: This column contains the original name of the stop that requires modification or mapping to another name. **cluster_name**: This column specifies the name to which the original stop name should be changed or mapped during the clustering process.

It utilizes the [DBSCAN](https://en.wikipedia.org/wiki/DBSCAN) Density-Based algorithm to perform clustering. I based my core algorithm on the gem [Dbscan](https://github.com/matiasinsaurralde/dbscan)

### Stops config file example

Here is an example of a stops_config CSV file:

```csv
stop_name,cluster_name
Stop Name To Be Changed,Actual Name
Amargosa Valley (Demo),Amargosa Valley
E Main St / S Irving St (Demo),E Main St / S Irving St
```

In this case, passing this CSV file to the clustering algorithm, **Amargosa Valley (Demo)** will be renamed **Amargarosa Valley**, and so on for all the entries provided. The reason why I needed to implement this feature is simply because I was dealing with bad stops names (typo) provided by default within the GTFS I was working on.

## Requirements

It is essential to have a **Redis server instance running locally** because the algorithm leverages Redis geospatial queries for efficient spatial operations.
The Redis server is utilized to optimize geospatial queries, allowing the clustering algorithm to efficiently process proximity-related computations required during the clustering process.
Please ensure that a Redis server is installed and running on your local machine to utilize the gem effectively.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gtfs_stops_clustering', '~> 0.1.5'
```
And run the following command

```bash
$ bundle install
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install gtfs_stops_clustering
```

## Usage

```ruby
require 'gtfs_stops_clustering'
include GtfsStopsClustering

gtfs_paths = ["path/to/gtfs/zip"]

clusters = build_clusters(urls, 0.3, 1, 0.85)

clusters.each do |index, cluster|
  puts index
  cluster.each do |stop|
    puts stop.inspect
  end
end
```

In this case, I'm showing the output referred to the GTFS file located in `test/fixtures/sample-feed-2.zip` (which is the sample-feed provided by Google, but changed a bit in order to create "clusterable" stops since they all were too far to be clustered). In this case I omitted the optional parameter `stops config`

```
-1
{:stop_id=>"4", :stop_code=>nil, :cluster_name=>nil, :cluster_pos=>[], :stop_name=>"Stagecoach Hotel & Casino (Demo)", :stop_lat=>"36.915682", :stop_lon=>"-116.751677", :parent_station=>nil}
{:stop_id=>"6", :stop_code=>nil, :cluster_name=>nil, :cluster_pos=>[], :stop_name=>"Alone stop (sad)", :stop_lat=>"36.914944", :stop_lon=>"-116.761472", :parent_station=>nil}
{:stop_id=>"8", :stop_code=>nil, :cluster_name=>nil, :cluster_pos=>[], :stop_name=>"E Main St / S Irving St (Demo)", :stop_lat=>"36.905697", :stop_lon=>"-116.76218", :parent_station=>nil}
{:stop_id=>"9", :stop_code=>nil, :cluster_name=>nil, :cluster_pos=>[], :stop_name=>"Amargosa Valley (Demo)", :stop_lat=>"36.641496", :stop_lon=>"-116.40094", :parent_station=>nil}
0
{:stop_id=>"1", :stop_code=>nil, :cluster_name=>"Awesome Stop Name", :cluster_pos=>[36.425286, -117.133156], :stop_name=>"Awesome stop name 1", :stop_lat=>"36.425288", :stop_lon=>"-117.133162", :parent_station=>nil}
{:stop_id=>"5", :stop_code=>nil, :cluster_name=>"Awesome Stop Name", :cluster_pos=>[36.425286, -117.133156], :stop_name=>"Awesome stop name 2", :stop_lat=>"36.425284", :stop_lon=>"-117.133150", :parent_station=>nil}
1
{:stop_id=>"2", :stop_code=>nil, :cluster_name=>"Nye County Airport", :cluster_pos=>[36.868429, -116.78467699999999], :stop_name=>"Nye County Airport A1", :stop_lat=>"36.868446", :stop_lon=>"-116.784582", :parent_station=>nil}
{:stop_id=>"3", :stop_code=>nil, :cluster_name=>"Nye County Airport", :cluster_pos=>[36.868429, -116.78467699999999], :stop_name=>"Nye County Airport A2", :stop_lat=>"36.868417", :stop_lon=>"-116.784352", :parent_station=>nil}
{:stop_id=>"7", :stop_code=>nil, :cluster_name=>"Nye County Airport", :cluster_pos=>[36.868429, -116.78467699999999], :stop_name=>"Nye County Airport A5", :stop_lat=>"36.868424", :stop_lon=>"-116.785097", :parent_station=>nil}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gtfs_stops_clustering. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/gtfs_stops_clustering/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GtfsStopsClustering project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gtfs_stops_clustering/blob/main/CODE_OF_CONDUCT.md).
