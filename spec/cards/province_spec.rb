require 'spec_helper'

describe 'Province' do
  let(:card_name) { 'province' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 6 points' do
      expect(@card.value(nil)).to eq(6)
    end
  end

end
