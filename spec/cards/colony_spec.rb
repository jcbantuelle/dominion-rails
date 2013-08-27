require 'spec_helper'

describe 'Colony' do
  let(:card_name) { 'colony' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 10 points' do
      expect(@card.value(nil)).to eq(10)
    end
  end

end
