require 'spec_helper'

describe 'Tactician' do

  let(:card_name) { 'tactician' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    context 'with an empty hand' do
      it 'does not count towards the duration event' do
        @subject.play_card
        @turn.reload
        expect(@turn.tacticians).to eq(0)
      end
    end

    context 'with cards in hand' do
      it 'discards your hand and counts towards the duration event' do
        2.times do
          PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
        end
        @subject.play_card
        @turn.reload
        expect(@turn.tacticians).to eq(1)
        expect(@game_player.hand.count).to eq(0)
      end
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +5 cards, +1 buy, +1 action' do
      11.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @turn.update tacticians: 1
      @subject.next_turn
      expect(@game.current_turn.buys).to eq(2)
      expect(@game.current_turn.actions).to eq(2)
      expect(@game_player.hand.count).to eq(10)
    end
  end

end
