require 'spec_helper'

describe 'Crossroads' do
  let(:card_name) { 'crossroads' }
  include_context 'setup'

  describe '#play' do

    include_context 'play card'

    context 'first crossroad played' do
      it 'gives +3 actions' do
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(3)
      end
    end

    context 'second crossroad played' do
      it 'gives no extra actions' do
        @turn.update crossroads: 1
        @subject.play_card
        @turn.reload
        expect(@turn.actions).to eq(0)
      end
    end

    it 'gives +1 card per victory card in hand' do
      estate = Card.find(Card.create(name: 'estate'))
      2.times do
        PlayerCard.create game_player: @game_player, card: estate, state: 'hand'
      end
      PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
      3.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      expect(@game_player.hand.count).to eq(5)
    end
  end
end
