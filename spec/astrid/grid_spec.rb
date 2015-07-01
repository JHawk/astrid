require 'spec_helper'
require 'astrid/grid'

describe Astrid::Grid do

  describe '#visited?' do
    let(:grid) { Astrid::Grid.new(10,10) }

    subject { grid.visited?({x: 0, y: 0})}

    context 'when not visited' do
      let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil} }

      before do
        grid.update(node)
      end

      it { is_expected.to be_falsey }
    end

    context 'when opened' do
      let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true} }

      before do
        grid.update(node)
      end

      it { is_expected.to be_truthy }
    end

    context 'when closed' do
      let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true, closed: true} }

      before do
        grid.update(node)
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#empty' do
    let(:grid) { Astrid::Grid.new(10,10) }
    let(:p) { {x: 0, y: 0} }
    let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true, closed: true} }

    before do
      grid.update(node)
    end

    subject { grid.empty(p)}

    it 'un visits the position' do
      subject

      expect(grid.visited?(p)).to be_falsey
    end
  end

  describe '#closed?' do
    let(:grid) { Astrid::Grid.new(10,10) }

    subject { grid.closed?({x: 0, y: 0})}

    context 'when unvisited' do
      it { is_expected.to be_falsey }
    end

    context 'when opened' do
      before do
        grid.update(node)
      end

      context 'when not closed' do
        let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true} }

        it { is_expected.to be_falsey }
      end

      context 'when closed' do
        let(:node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true, closed: true} }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#close' do
    let(:grid) { Astrid::Grid.new(10,10) }
    let(:p) { {x: 0, y: 0} }

    subject { grid.close(p)}

    it 'closes the position' do
      subject

      expect(grid.opened?(p)).to be_truthy
      expect(grid.closed?(p)).to be_truthy
    end
  end

  describe '#opened?' do
    let(:grid) { Astrid::Grid.new(10,10) }

    subject { grid.opened?({x: 0, y: 0})}

    context 'when not opened' do
      it { is_expected.to be_falsey }
    end

    context 'when opened' do
      let(:opened_node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true} }

      before do
        grid.update(opened_node)
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#open' do
    let(:grid) { Astrid::Grid.new(10,10) }
    let(:p) { {x: 0, y: 0} }

    subject { grid.open(p)}

    it 'opens the position' do
      subject

      expect(grid.opened?(p)).to be_truthy
    end
  end

  describe "#visited_positions" do
    let(:closed_node) { {x: 0, y: 0, f: 0, g: 0, h: nil, opened: true, closed: true} }
    let(:opened_node) { {x: 0, y: 1, f: 0, g: 0, h: nil, opened: true} }

    let(:grid) { Astrid::Grid.new(10,10) }

    before do
      grid.update(opened_node)
      grid.update(closed_node)
      grid.empty({x: 0, y: 2})
    end

    subject { grid.visited_positions }

    it { is_expected.to include(closed_node) }
    it { is_expected.to include(opened_node) }

    it 'has the correct length' do
      positions = subject

      expect(positions.count).to eq(2)
    end
  end

  describe "#create" do
    context "when | on map" do
      subject do
        Astrid::Grid.create(<<-G)
.|.
.|.
        G
      end

      it 'makes the | not walkable' do
        grid = subject

        expect(grid.walkable?([1,0])).to be_falsey
      end
    end

    context "when _ on map" do
      subject do
        Astrid::Grid.create(<<-G)
._.
._.
        G
      end

      it 'makes the _ not walkable' do
        grid = subject

        expect(grid.walkable?([1,0])).to be_falsey
      end
    end
  end
end
