require 'pry'
module Astrid
  class Grid
    attr_accessor :max_x, :max_y, :inner_grid

    class << self
      def create(str)
        normalize = str.lines.reverse

        max_x = normalize.map(&:length).max
        max_y = normalize.length

        grid = self.new(max_x,max_y)

        y_idx = 0
        normalize.each do |line|
          line.each_char.each_with_index do |c, x_idx|
            if c == '|' || c == '_'
              grid.walkable([x_idx,y_idx], false)
            end
          end
          y_idx += 1
        end
        grid
      end
    end

    def initialize(max_x,max_y)
      @max_x = max_x
      @max_y = max_y
      @inner_grid = {}
    end

    def close(v)
      node = find_or_create_at(v)
      node[:opened] = true
      node[:closed] = true
    end

    def walkable(v, is_walkable)
      node = find_or_create_at(v)
      node[:walkable] = is_walkable
    end

    def open(v)
      node = find_or_create_at(v)
      node[:opened] = true
    end

    def empty(v)
      k = v.is_a?(Hash) ? [v[:x], v[:y]] : v
      create_empty_node_at(k)
    end

    def closed?(v)
      node = find_at(v)
      node && node[:closed]
    end

    def walkable?(v)
      node = find_at(v)
      !node || node[:walkable].nil? || node[:walkable]
    end

    def opened?(v)
      node = find_at(v)
      node && node[:opened]
    end

    def visited?(v)
      node = find_at(v)
      node && (node[:opened] || node[:closed])
    end

    def update(v)
      k = [v[:x], v[:y]]
      @inner_grid[k] = v
    end

    def visited_positions
      @inner_grid.select do |k,v|
        k.is_a?(Array) && (v[:opened] || v[:closed])
      end.map {|a| a[1]}
    end

    private

    def create_empty_node_at(k)
      @inner_grid[k] = empty_node(k)
    end

    def empty_node(k)
      {x: k[0], y: k[1], f: 0, g: 0, h: nil}
    end

    def find_or_empty_at(k)
      @inner_grid[k] || empty_node(k)
    end

    def find_at(v)
      k = v.is_a?(Hash) ? [v[:x], v[:y]] : v
      @inner_grid[k]
    end

    def find_or_create_at(v)
      k = v.is_a?(Hash) ? [v[:x], v[:y]] : v
      @inner_grid[k] || create_empty_node_at(k)
    end
  end
end
