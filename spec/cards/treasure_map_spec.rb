require 'spec_helper'

describe 'Treasure Map' do
  let(:card_name) { 'treasure_map' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    context 'with another treasure map in hand' do

      it 'trashes both treasure maps and puts 4 gold on deck' do
        gold = Card.find(Card.create(name: 'gold'))
        GameCard.create game: @game, card: gold, remaining: 20
        PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
        @subject.play_card
        expect(@game_player.hand.count).to eq(0)
        expect(@game_player.deck.count).to eq(4)
        expect(@game.game_trashes.count).to eq(2)
      end
    end

    context 'without another treasure map in hand' do

      it 'trashes the treasure map and gives nothing' do
        @subject.play_card
        expect(@game_player.hand.count).to eq(0)
        expect(@game_player.deck.count).to eq(0)
        expect(@game.game_trashes.count).to eq(1)
      end
    end
  end
end
