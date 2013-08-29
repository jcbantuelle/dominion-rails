require 'spec_helper'

describe 'Peddler' do
  let(:card_name) { 'peddler' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +$1, +1 card, +1 action' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(1)
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end
  end

  describe '#cost' do

    before(:each) do
      @peddler = Card.find(@card.id)
    end

    context 'during action phase' do
      it 'is not discounted' do
        @turn.update played_actions: 2
        expect(@peddler.cost(@game)[:coin]).to eq(8)
      end
    end

    context 'during treasure phase' do
      it 'is is discounted' do
        @turn.update played_actions: 2, phase: 'treasure'
        expect(@peddler.cost(@game)[:coin]).to eq(4)
      end

      it 'does not go below zero' do
        @turn.update played_actions: 5, phase: 'treasure'
        expect(@peddler.cost(@game)[:coin]).to eq(0)
      end
    end
  end
end
