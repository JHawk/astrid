require 'astrid/heuristics/manhattan'

module Astrid
  module Finders
    class AStar

      attr_accessor :allow_diagonal, :current_grid, :current_path

      def initialize(opts={})
        @allow_diagonal = opts[:allow_diagonal] || false
        @heuristic = opts[:heuristic] || Heuristics::Manhattan
#        @diagonal_movement = opts[:diagonal_movement]
        @weight = opts[:weight] || 1;
      end

      def sanitize(node)
        node
      end

      # A*
      # requires x & y
      # node = g, f, h, x, y, opened, walkable, closed, parent
      # clearly not optomized at all!
      def find_path(start_node, end_node, grid)
        start_node = sanitize(start_node)
        end_node = sanitize(end_node)
        if grid.nil?
          [start_node]
        else
          @current_grid = grid.clone
          _max_x = grid[:max_x]
          _max_y = grid[:max_y]

          raise 'max_x & max_y required' unless _max_x && _max_y

          _start_node = start_node.clone
          _end_node = end_node.clone

          heuristic = @heuristic.new(_end_node, @weight)

          _start_node[:f] = 0   # sum of g and h
          _start_node[:g] = 0   # steps to start node
          _start_node[:h] = nil # steps to end node
          _start_node[:opened] = true

          # use heap or tree for better perf
          open = []
          open.push _start_node

          while !open.empty? do
            _current_node = open.pop

            _current_node[:closed] = true
            @current_grid[node_to_a(_current_node)] = _current_node

            if node_to_a(_current_node) == node_to_a(_end_node)
              return final_path(_current_node)
            end

            new_g = _current_node[:g] + 1

            x = _current_node[:x]
            y = _current_node[:y]

            neighbors = []

            neighbors << [x-1, y] if x > 0
            neighbors << [x, y-1] if y > 0
            neighbors << [x+1, y] if x < _max_x-1
            neighbors << [x, y+1] if y < _max_y-1

            _neighbors = neighbors.map do |position|
              node = @current_grid[position]
              if node.nil? || node[:walkable]
                node ||= {}
                @current_grid[position] = node.merge({
                  x: position.first,
                  y: position[1],
                  closed: false,
                  opened: false
                })
              end
            end.compact

            _neighbors.each do |neighbor|
              if (!neighbor[:opened] || new_g < neighbor[:g])
                neighbor[:g] = new_g
                neighbor[:h] ||= heuristic.h(neighbor)
                neighbor[:f] = neighbor[:g] + neighbor[:h]
                neighbor[:parent] = node_to_a(_current_node)

                if (!neighbor[:opened])
                  open.push neighbor
                  neighbor[:opened] = true
                else
                  # ???
                  puts "got here some how!!!"
                end
              end
            end

            open.sort_by! {|i| [-i[:f], -i[:h]]}
            # grid_p
          end
        end
      end

      def final_path(_end_node)
        path = [_end_node]
        _current_node = _end_node

        while _current_node[:parent] do
          parent_position = _current_node[:parent]
          parent_node = @current_grid[parent_position]

          path << parent_node
          _current_node = parent_node
        end

        @current_path = path.reverse
      end

      def find_path_a(start_node, end_node, grid)
        p = find_path(start_node, end_node, grid)
        if p
          p.map do |node|
            node_to_a(node)
          end
        end
      end

      def find_path_a_with_time(start_node, end_node, grid)
        result, time = find_path_a(start_node, end_node, grid)
      end

      def grid_p
        puts ""
        puts "#"*80
        s = ""
        n = @current_grid[:max_y].to_s.size + 2
        (-@current_grid[:max_y]..0).each do |y|
          (0..@current_grid[:max_x]).each do |x|
            node = @current_grid[[x,-y]]
            if node
              if node[:walkable].nil? || node[:walkable]
                s << node[:f].to_s.rjust(n, " ")
              else
                s << "|".rjust(n, " ")
              end
            else
              s << ''.rjust(n, '.')
            end
          end
          s << "\n"
        end
        puts s
      end

      def node_to_a(node)
        [node[:x], node[:y]]
      end
    end
  end
end

