require 'spec_helper'

describe 'Wharf' do

  let(:card_name) { 'wharf' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +2 cards, +1 buy' do
      2.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      @turn.reload
      expect(@turn.buys).to eq(2)
      expect(@game_player.hand.count).to eq(2)
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +2 cards, +1 buy' do
      8.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.next_turn
      expect(@game.current_turn.buys).to eq(2)
      expect(@game_player.hand.count).to eq(7)
    end
  end

end
