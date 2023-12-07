# lib/input_consistency_checks.rb


module InputConsistencyChecks

  class InputConsistencyChecks
    attr_accessor :gtfs_paths, :epsilon, :min_points, :names_similarity, :stops_config_path

    def initialize(gtfs_paths, epsilon, min_points, names_similarity, stops_config_path)
      @gtfs_paths = gtfs_paths
      @stops_config_path = stops_config_path
      @epsilon = epsilon
      @min_points = min_points
      @names_similarity = names_similarity
      input_consistency_checks
    end

    def input_consistency_checks
      gtfs_paths_check
      epsilon_check
      min_points_check
      names_similarity_check
    end

    def gtfs_paths_check
      raise ArgumentError, "gtfs_paths cannot be nil" if @gtfs_paths.nil?
      raise ArgumentError, "gtfs_paths must be an Array" unless @gtfs_paths.is_a?(Array)
      raise ArgumentError, "gtfs_paths must not be empty" if @gtfs_paths.empty?
    end

    def epsilon_check
      raise ArgumentError, "epsilon must be a Float" unless @epsilon.is_a?(Float)
      raise ArgumentError, "epsilon must be greater than 0" if @epsilon.negative?
    end

    def min_points_check
      raise ArgumentError, "min_points must be an Integer" unless @min_points.is_a?(Integer)
      raise ArgumentError, "min_points must be greater than 0" if @min_points.negative?
    end

    def names_similarity_check
      raise ArgumentError, "names_similarity must be a Float" unless @names_similarity.is_a?(Float)
      raise ArgumentError, "names_similarity must be between 0 and 1" if @names_similarity.negative? || @names_similarity > 1
    end
  end

  def input_consistency_checks(gtfs_paths, epsilon, min_points, names_similarity, stop_config_path)
    @input_consistency_checks = InputConsistencyChecks.new(gtfs_paths, epsilon, min_points, names_similarity, stop_config_path)
  end
end
