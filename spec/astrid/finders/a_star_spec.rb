require 'spec_helper'
require 'astrid/finders/a_star'

describe 'Pathfinder::Finders::AStar' do


  let(:a_star) { Pathfinder::Finders::AStar.new }

  describe "#grid" do
    describe "#visited_positions" do
      let(:closed) { {:x=>0, :y=>0, :f=>0, :g=>0, :h=>nil, :opened=>true, :closed=>true} }
      let(:opened) { {:x=>0, :y=>0, :f=>0, :g=>0, :h=>nil, :opened=>true} }
      let(:not_visited) { {:x=>0, :y=>0, :f=>0, :g=>0, :h=>nil} }

      let(:grid) do
        {
          :max_x => 10,
          :max_y => 10,

          [0,0] => closed,
          [0,1] => opened,
          [0,2] => not_visited
        }
      end

      before do
        a_star.current_grid = grid
      end

      subject { a_star.visited_positions }

      it { is_expected.to include(closed) }
      it { is_expected.to include(opened) }
      it { is_expected.not_to include(not_visited) }
    end

    describe "#grid_from_s_map" do
      context "when | on map" do
        subject do
          a_star.grid_from_s_map(<<-G)
.|.
.|.
          G
        end

        it 'makes the | not walkable' do
          grid = subject

          expect(grid[[1,0]][:walkable]).to be_falsey
        end
      end

      context "when _ on map" do
        subject do
          a_star.grid_from_s_map(<<-G)
._.
._.
          G
        end

        it 'makes the _ not walkable' do
          grid = subject

          expect(grid[[1,0]][:walkable]).to be_falsey
        end
      end
    end
  end

  describe "#find_path" do
    context 'timed' do
      subject { a_star.find_path_a_with_time(position1, position2, grid) }

      context 'origin to 100,100' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 100, y: 100} }
        let(:grid) { {max_x:10000, max_y:10000} }

        it 'should not take too long' do
          path = subject

          expect(path).to include([0,0])
          expect(path).to include([100,100])
        end
      end
    end

    context 'no diagonals' do
      subject { a_star.find_path_a(position1, position2, grid) }

      context 'origin to origin' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 0, y: 0} }
        let(:grid) { {max_x:10, max_y:10} }

        it { is_expected.to eq([[0,0]]) }
      end

      context 'origin to 1,1' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 1, y: 1} }

        context "when grid is nil" do
          let(:grid) { nil }

          it { is_expected.to eq([[0,0]]) }
        end

        context "when grid contains start and end" do
          let(:grid) { {max_x:2, max_y:2} }

          it { is_expected.to eq([[0,0],[0,1],[1,1]]) }
        end
      end

      context 'origin to 2,2' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 2, y: 2} }
        let(:grid) { {max_x:5, max_y:5} }

        it { is_expected.to include([0,0]) }
        it { is_expected.to include([2,2]) }

        it 'has the correct length' do
          path = subject

          expect(path.length).to eq(5)
        end
      end

      context 'unsolvable' do
        context '1' do
          let(:grid) {
            a_star.grid_from_s_map(<<-G)
....|......
.1..|..2...
....|......
            G
          }

          let(:position1) { {x: 1, y: 1} }
          let(:position2) { {x: 7, y: 1} }

          it { is_expected.to be_nil }
        end

      end

      context 'obstructed paths' do
        context '1' do
          let(:grid) {
            a_star.grid_from_s_map(<<-G)
........
...........
...........
...........
....|......
.1..|..2...
....|......
..........
...........
            G
          }

          let(:position1) { {x: 1, y: 3} }
          let(:position2) { {x: 7, y: 3} }

          it { is_expected.to include([1,3]) }
          it { is_expected.to include([7,3]) }

          it { is_expected.not_to include([4,2]) }
          it { is_expected.not_to include([4,3]) }
          it { is_expected.not_to include([4,4]) }

          it 'has the correct length' do
            path = subject
            expect(path.length).to eq(11)
          end

          it 'should only visit necessary positions' do
            subject

            expect(a_star.current_grid).not_to be_nil
            expect(a_star.visited_positions.count).to eq(31)
          end
        end

        context '2' do
          let(:grid) {
            a_star.grid_from_s_map(<<-G)
......|.....
.1....|.....
......|.....
......|.....
......|..2..
......|.....
......|.....
............
............
............
............
            G
          }

          let(:position1) { {x: 1, y: 10} }
          let(:position2) { {x: 9, y: 6} }

          it { is_expected.to include([1,10]) }
          it { is_expected.to include([9,6]) }

          it { is_expected.not_to include([6,4]) }
          it { is_expected.not_to include([6,5]) }
          it { is_expected.not_to include([6,6]) }
          it { is_expected.not_to include([6,7]) }
          it { is_expected.not_to include([6,8]) }
          it { is_expected.not_to include([6,9]) }
          it { is_expected.not_to include([6,10]) }
          it { is_expected.not_to include([6,11]) }

          it 'has the correct length' do
            path = subject

            expect(path.length).to eq(19)
          end
        end
      end
    end
  end
end
