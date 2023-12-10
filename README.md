# GTFS Stops clustering

GTFS Stops Clustering is a Ruby Gem designed to read [GTFS](https://gtfs.org) (General Transit Feed Specification) stops data and create clusters based on the following parameters:

- **Epsilon** (float): the maximum distance (in km) between 2 stops for them to be considered neighbors of one another (e.g.: 0.01, 0.5, 2 etc.)
- **Min Points** (int): the minimum number of neighbors a point needs to have to be considered a core point (e.g.: 3, 5, 10 etc.)
- **Names Similarity** (string): Besides geographical proximity, the algorithm also considers the similarity between stop names using techniques like string similarity measures. This enhances the clustering by including stops with similar names within the same cluster (e.g.: all values between 0 and 1. The more the value is in proximity of 1, the more similar the stop names need to be considered points of the same cluster). The default value is 1, so if you want to create clusters based only on stop positions, leave this to 0.
- **Stop config file** (CSV file path): This file is specifically designed to handle certain cases where stop names need to be altered or mapped to different names before running the clustering algorithm. Each entry consists of two columns:
**stop_name**: This column contains the original name of the stop that requires modification or mapping to another name. **cluster_name**: This column specifies the name to which the original stop name should be changed or mapped during the clustering process.

It utilizes the [DBSCAN](https://en.wikipedia.org/wiki/DBSCAN) Density-Based algorithm to perform clustering.
## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gtfs_stops_clustering. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/gtfs_stops_clustering/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GtfsStopsClustering project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gtfs_stops_clustering/blob/main/CODE_OF_CONDUCT.md).
