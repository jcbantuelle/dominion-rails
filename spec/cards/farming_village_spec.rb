require 'spec_helper'

describe 'Farming Village' do
  let(:card_name) { 'farming_village' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    before(:each) do
      estate = Card.find(Card.create(name: 'estate').id)
      5.times do |i|
        PlayerCard.create game_player: @game_player, card: estate, state: 'deck', card_order: i
      end
    end

    it 'discards revealed cards' do
      @subject.play_card
      expect(@game_player.discard.count).to eq(5)
    end

    context 'with a revealed action' do
      it 'puts the action in hand' do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 6
        @subject.play_card
        expect(@game_player.hand.count).to eq(1)
      end
    end

    context 'with a revealed treasure' do
      it 'puts the treasure in hand' do
        treasure = Card.find(Card.create(name: 'copper').id)
        PlayerCard.create game_player: @game_player, card: treasure, state: 'deck', card_order: 6
        @subject.play_card
        expect(@game_player.hand.count).to eq(1)
      end
    end
  end
end
