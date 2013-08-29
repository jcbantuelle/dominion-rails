require 'spec_helper'

describe 'Venture' do
  let(:card_name) { 'venture' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    before(:each) do
      @non_treasure = Card.find(Card.create(name: 'village').id)
      5.times do |i|
        PlayerCard.create game_player: @game_player, card: @non_treasure, state: 'deck', card_order: i
      end
    end

    it 'discards revealed cards' do
      @subject.play_card
      expect(@game_player.discard.count).to eq(5)
    end

    context 'revealing a standard treasure' do
      it 'plays the treasure' do
        gold = Card.find(Card.create(name: 'gold'))
        PlayerCard.create game_player: @game_player, card: gold, state: 'deck', card_order: 6
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(4)
      end
    end

    context 'revealing a venture' do
      it 'chains ventures' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 6
        gold = Card.find(Card.create(name: 'gold'))
        PlayerCard.create game_player: @game_player, card: gold, state: 'deck', card_order: 7
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(5)
      end
    end
  end
end
