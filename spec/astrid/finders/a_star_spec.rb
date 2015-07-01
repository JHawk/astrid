require 'spec_helper'
require 'astrid/grid'
require 'astrid/finders/a_star'

describe Astrid::Finders::AStar do
  let(:a_star) { Astrid::Finders::AStar.new }

  describe "#find_path" do
    context 'timed' do
      subject { a_star.find_path_a_with_time(position1, position2, grid) }

      context 'origin to 100,100' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 100, y: 100} }
        let(:grid) { Astrid::Grid.new(10000,10000) }

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
        let(:grid) { Astrid::Grid.new(10,10) }

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
          let(:grid) { Astrid::Grid.new(2,2) }

          it { is_expected.to eq([[0,0],[0,1],[1,1]]) }
        end
      end

      context 'origin to 2,2' do
        let(:position1) { {x: 0, y: 0} }
        let(:position2) { {x: 2, y: 2} }
        let(:grid) { Astrid::Grid.new(5,5) }

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
            Astrid::Grid.create(<<-G)
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
            Astrid::Grid.create(<<-G)
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
            #expect(grid.visited_positions.count).to eq(31)
          end
        end

        context '2' do
          let(:grid) {
            Astrid::Grid.create(<<-G)
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

