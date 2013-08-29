require 'spec_helper'

describe 'Hunting Party' do
  let(:card_name) { 'hunting_party' }
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
      expect(@game_player.discard.count).to eq(4)
    end

    it 'gives +1 card, +1 action, and puts the first unique card into hand' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck', card_order: 6
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(2)
    end
  end
end
