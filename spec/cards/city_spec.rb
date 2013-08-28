require 'spec_helper'

describe 'City' do
  let(:card_name) { 'city' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    before(:each) do
      3.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
    end

    context 'with two empty piles' do
      it 'gives +2 cards, +2 actions, +1 buy, +$1' do
        2.times do
          GameCard.create game: @game, card: @card, remaining: 0
        end
        @subject.play_card
        @turn.reload
        expect(@turn.buys).to eq(2)
        expect(@turn.coins).to eq(1)
        expect(@turn.actions).to eq(2)
        expect(@game_player.hand.count).to eq(2)
      end
    end

    context 'with one empty pile' do
      it 'gives +2 cards, +2 actions' do
        GameCard.create game: @game, card: @card, remaining: 0
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(2)
        expect(@game_player.hand.count).to eq(2)
      end
    end

    context 'with no empty piles' do
      it 'gives +1 card, +2 actions' do
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(2)
        expect(@game_player.hand.count).to eq(1)
      end
    end
  end
end
