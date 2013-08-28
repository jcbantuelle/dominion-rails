require 'spec_helper'

describe 'Market' do
  let(:card_name) { 'market' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@turn.coins).to eq(1)
      expect(@turn.buys).to eq(2)
      expect(@game_player.hand.count).to eq(1)
    end
  end
end
