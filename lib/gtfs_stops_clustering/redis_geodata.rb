# lib/redis_geodata.rb
require 'redis'

module RedisGeodata
  VERSION='0.0.1'
  attr_accessor :redis

  class RedisGeodata
    attr_accessor :stops, :key, :redis, :epsilon

    def initialize(stops, epsilon)
      @redis = Redis.new(url: 'redis://127.0.0.1:6379')
      @stops = stops
      @key = 'stops'
      @epsilon = epsilon
      geoadd
    end

    def geoadd
      @redis.geoadd(@key, *@stops)
      @redis.expire(@key, 100_000_0)
    end

    def geosearch(longitude, latitude)
      list = @redis.georadius(@key, longitude, latitude, @epsilon, 'km')
      list.reject! { |point| point == longitude.to_s + "," + latitude.to_s }
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

include RedisGeodata
