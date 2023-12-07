# frozen_string_literal: true

# lib/data_import.rb

require "csv"
require "gtfs"

# DataImport module
module DataImport
  attr_accessor :data_import

  # DataImport class
  class DataImport
    attr_accessor :stops, :stops_config_file, :stops_names, :stops_corner_cases, :stops_data, :stops_redis_geodata

    def initialize(stops, stops_config_file)
      @stops = stops
      @stops_config_file = stops_config_file
      @stops_corner_cases = []
      @stops_names = []
      @stops_data = []
      @stops_redis_geodata = []
      import_stops_corner_cases
      import_stops_data
    end

    def import_stops_corner_cases
      return unless File.exist?(@stops_config_file)

      CSV.foreach(@stops_config_file, headers: true) do |row|
        stop_name = row["stop_name"]
        cluster_name = row["cluster_name"]

        stops_corner_cases << { stop_name: stop_name, cluster_name: cluster_name }
      end
    end

    def import_stops_data
      @stops.each do |row|
        latitude = row.lat
        longitude = row.lon
        stop_name = row.name

        stop_name = stop_name_from_corner_cases(stop_name)

        @stops_names << stop_name
        @stops_data << [latitude, longitude]
        @stops_redis_geodata << [longitude, latitude, "#{longitude},#{latitude}"]
      end
    end

    def stop_name_from_corner_cases(stop_name)
      csv_entry = @stops_corner_cases.find do |entry|
        entry[:stop_name] == stop_name
      end
      csv_entry.nil? ? stop_name : csv_entry[:cluster_name]
    end
  end

  def import_stops_data(*args)
    @data_import = DataImport.new(*args)
    {
      stops_data: @data_import.stops_data,
      stops_names: @data_import.stops_names,
      stops_redis_geodata: @data_import.stops_redis_geodata
    }
  end
end
