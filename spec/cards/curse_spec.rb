require 'spec_helper'

describe 'Curse' do
  let(:card_name) { 'curse' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth -1 point' do
      expect(@card.value(nil)).to eq(-1)
    end
  end

end
