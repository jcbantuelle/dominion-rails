require 'spec_helper'

describe 'Conspirator' do
  let(:card_name) { 'conspirator' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    context 'with less than 3 actions in play' do
      it 'gives +$2' do
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(2)
      end
    end

    context 'with 3 actions in play' do
      it 'gives +$2, +1 card, +1 action' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
        @turn.update played_actions: 2
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(2)
        expect(@turn.actions).to eq(1)
        expect(@game_player.hand.count).to eq(1)
      end
    end
  end
end
