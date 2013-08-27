require 'spec_helper'

describe 'Woodcutter' do
  let(:card_name) { 'woodcutter' }

  include_context "play card"

  describe '#play' do
    it 'updates the game state' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
      expect(@turn.buys).to eq(2)
    end
  end
end
