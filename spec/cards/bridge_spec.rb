require 'spec_helper'

describe 'Bridge' do
  let(:card_name) { 'bridge' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(1)
      expect(@turn.buys).to eq(2)
      expect(@turn.global_discount).to eq(1)
    end
  end
end
