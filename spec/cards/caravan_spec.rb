require 'spec_helper'

describe 'Caravan' do

  let(:card_name) { 'caravan' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +1 card, +1 action' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +1 card' do
      6.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.next_turn
      expect(@game_player.hand.count).to eq(6)
    end
  end

end
