# frozen_string_literal: true

# lib/gtfs_stops_clustering/redis_geodata.rb

require "redis"

# RedisGeodata module
module RedisGeodata
  attr_accessor :redis

  # RedisGeodata class
  class RedisGeodata
    attr_accessor :stops, :key, :redis, :epsilon

    def initialize(stops, epsilon)
      begin
        @redis = Redis.new(url: "redis://127.0.0.1:6379")
      rescue Redis::CannotConnectError => e
        raise RuntimeError "Error occurred while connecting to Redis: #{e.message}"
      end
      @stops = stops
      @key = "stops"
      @epsilon = epsilon
      geoadd
    end

    def geoadd
      @redis.del(@key)
      @redis.geoadd(@key, *@stops)
      @redis.expire(@key, 100_000_0)
    end

    def geosearch(longitude, latitude)
      list = @redis.georadius(@key, longitude, latitude, @epsilon, "km")
      list.reject! { |point| point == "#{longitude},#{latitude}" }
      list
    end
  end

  def redis_geodata_import(*args)
    @redis = RedisGeodata.new(*args)
  end

  def geosearch(*args)
    @redis.geosearch(*args)
  end
end
