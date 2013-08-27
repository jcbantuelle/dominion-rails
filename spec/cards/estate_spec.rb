require 'spec_helper'

describe 'Estate' do
  let(:card_name) { 'estate' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 points' do
      expect(@card.value(nil)).to eq(1)
    end
  end

end
