require 'spec_helper'

describe 'Laboratory' do
  let(:card_name) { 'laboratory' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +2 cards, +1 action' do
      2.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(2)
    end
  end
end
