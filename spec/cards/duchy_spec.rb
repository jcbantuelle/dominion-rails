require 'spec_helper'

describe 'Duchy' do
  let(:card_name) { 'duchy' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 3 points' do
      expect(@card.value(nil)).to eq(3)
    end
  end

end
