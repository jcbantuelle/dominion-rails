require 'spec_helper'

describe 'Menagerie' do
  let(:card_name) { 'menagerie' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    context 'with duplicates in hand' do
      it 'gives +1 action, +1 card' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
        2.times do
          PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
        end
        @subject.play_card
        expect(@turn.actions).to eq(1)
        expect(@game_player.hand.count).to eq(3)
      end
    end

    context 'without duplicates in hand' do
      it 'gives +1 action, +3 cards' do
        4.times do
          PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
        end
        PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(1)
        expect(@game_player.hand.count).to eq(4)
      end
    end
  end
end
