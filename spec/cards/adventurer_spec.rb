require 'spec_helper'

describe 'Adventurer' do
  let(:card_name) { 'adventurer' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    before(:each) do
      5.times do |i|
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: i
      end
      @treasure = Card.find(Card.create(name: 'copper').id)
    end

    it 'discards revealed cards' do
      @subject.play_card
      expect(@game_player.discard.count).to eq(5)
    end

    context 'with two treasures in deck' do
      it 'puts both treasures in hand' do
        2.times do |i|
          PlayerCard.create game_player: @game_player, card: @treasure, state: 'deck', card_order: i+5
        end
        @subject.play_card
        expect(@game_player.hand.count).to eq(2)
      end
    end

    context 'with one treasure in deck' do
      it 'puts one treasure in hand' do
        PlayerCard.create game_player: @game_player, card: @treasure, state: 'deck', card_order: 6
        @subject.play_card
        expect(@game_player.hand.count).to eq(1)
      end
    end

    context 'with no treasures in deck' do
      it 'puts no cards in hand' do
        @subject.play_card
        expect(@game_player.hand.count).to eq(0)
      end
    end
  end
end
