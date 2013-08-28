require 'spec_helper'

describe 'Great Hall' do
  let(:card_name) { 'great_hall' }

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

  describe '#value' do

    include_context 'victory card'

    it 'is worth 1 point' do
      expect(@card.value(nil)).to eq(1)
    end
  end
end
