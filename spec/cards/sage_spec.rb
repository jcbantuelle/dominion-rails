require 'spec_helper'

describe 'Sage' do
  let(:card_name) { 'sage' }
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

    it 'gives +1 action and puts the first card costing 3 or more in hand' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 6
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end
  end
end
