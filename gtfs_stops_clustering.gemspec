# frozen_string_literal: true

require_relative "lib/gtfs_stops_clustering/version"

Gem::Specification.new do |spec|
  spec.name = "gtfs_stops_clustering"
  spec.version = GtfsStopsClustering::VERSION
  spec.authors = ["Visco01"]
  spec.email = ["pietro.visconti2001@gmail.com"]

  spec.summary = "A gem to read GTFS stops data and create clusters based on coordinates and stop names' similarities."
  spec.description = "A gem to read GTFS stops data and create clusters based on coordinates and stop names' similarities."
  spec.homepage = "https://github.com/Visco01/gtfs_stops_clustering"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/Visco01/gtfs_stops_clustering/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (File.expand_path(f) == __FILE__) ||
  #       f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
  #   end
  # end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.files = ["lib/gtfs_stops_clustering.rb",
               "lib/gtfs_stops_clustering/data_import.rb",
               "lib/gtfs_stops_clustering/dbscan.rb",
               "lib/gtfs_stops_clustering/redis_geodata.rb",
               "lib/gtfs_stops_clustering/version.rb"]

  spec.add_runtime_dependency 'gtfs', '~> 0.4.1'
  spec.add_runtime_dependency 'distance_measures', '~> 0.0.6'
  spec.add_runtime_dependency 'text', '~> 1.3', '>= 1.3.1'
  spec.add_runtime_dependency 'geocoder', '~> 1.8', '>= 1.8.2'
  spec.add_runtime_dependency 'csv', '~> 3.2', '>= 3.2.8'
  spec.add_runtime_dependency 'redis', '~> 5.0', '>= 5.0.8'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
