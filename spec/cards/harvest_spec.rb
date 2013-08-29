require 'spec_helper'

describe 'Harvest' do
  let(:card_name) { 'harvest' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +$1 per differently named revealed card' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      copper = Card.find(Card.create(name: 'copper'))
      silver = Card.find(Card.create(name: 'silver'))
      PlayerCard.create game_player: @game_player, card: copper, state: 'deck'
      PlayerCard.create game_player: @game_player, card: silver, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(3)
      expect(@game_player.discard.count).to eq(4)
    end
  end
end
