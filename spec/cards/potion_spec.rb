require 'spec_helper'

describe 'Potion' do
  let(:card_name) { 'potion' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +1 potion' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.potions).to eq(1)
    end
  end
end
