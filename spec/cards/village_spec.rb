require 'spec_helper'

describe 'Village' do
  let(:card_name) { 'village' }

  include_context 'play card'

  describe '#play' do
    it 'gives +1 card, +2 actions' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(2)
      expect(@game_player.hand.count).to eq(1)
    end
  end
end
