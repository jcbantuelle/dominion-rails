require 'spec_helper'

describe 'Moneylender' do
  let(:card_name) { 'moneylender' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    context 'with copper in hand' do
      include_context 'market square card'

      before(:each) do
        copper = Card.find(Card.create(name: 'copper'))
        2.times do
          PlayerCard.create game_player: @game_player, card: copper, state: 'hand'
        end
      end

      it 'trashes a copper and gives +$3' do
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(3)
        expect(@game_player.hand.count).to eq(1)
        expect(@game.game_trashes.count).to eq(1)
      end
    end

    context 'without copper in hand' do

      it 'does nothing' do
        @subject.play_card
        @turn.reload
        expect(@turn.coins).to eq(0)
        expect(@game_player.hand.count).to eq(0)
        expect(@game.game_trashes.count).to eq(0)
      end
    end
  end
end
