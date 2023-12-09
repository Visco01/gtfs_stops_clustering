# frozen_string_literal: true

# lib/utils.rb

# Utils class
class Utils
  def self.find_cluster_name(labels)
    words = labels.map { |label| label.strip.split }
    common_title = ""

    # Loop through each word index starting from the first
    (0...words.first.length).each do |i|
      words_at_index = words.map { |word_list| word_list[i] }

      break unless words_at_index.uniq.length == 1

      common_title += " #{words_at_index.first.capitalize}"
    end

    common_title.strip! ? common_title : labels.first
  end

  def self.find_cluster_position(cluster)
    total_lat = cluster.map { |e| e.items[0].to_f }.sum
    total_lon = cluster.map { |e| e.items[1].to_f }.sum
    avg_lat = total_lat / cluster.size
    avg_lon = total_lon / cluster.size
    [avg_lat, avg_lon]
  end

  def self.string_similarity(str1, str2)
    string_distance = Text::Levenshtein.distance(str1.downcase, str2.downcase)
    1 - string_distance.to_f / [str1.length, str2.length].max
  end

  def self.find_inmediate_neighbor(neighbor_pos, points)
    coordinates_split = neighbor_pos.split(",")
    points.find do |elem|
      elem.items[0] == coordinates_split[1] &&
        elem.items[1] == coordinates_split[0]
    end
  end
end
