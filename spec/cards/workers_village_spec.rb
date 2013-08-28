require 'spec_helper'

describe 'Workers Village' do
  let(:card_name) { 'workers_village' }

  include_context 'play card'

  describe '#play' do
    it 'updates the game state' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.buys).to eq(2)
      expect(@turn.actions).to eq(2)
      expect(@game_player.hand.count).to eq(1)
    end
  end
end
