require 'spec_helper'

describe 'Festival' do
  let(:card_name) { 'festival' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
      expect(@turn.buys).to eq(2)
      expect(@turn.actions).to eq(2)
    end
  end
end
