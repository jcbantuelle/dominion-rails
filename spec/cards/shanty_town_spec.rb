require 'spec_helper'

describe 'Shanty Town' do
  let(:card_name) { 'shanty_town' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    context 'with actions in hand' do
      it 'gives +2 actions' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(2)
        expect(@game_player.hand.count).to eq(1)
      end
    end

    context 'without actions in hand' do
      it 'gives +2 actions, +2 cards' do
        3.times do
          PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
        end
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(2)
        expect(@game_player.hand.count).to eq(2)
      end
    end
  end
end
