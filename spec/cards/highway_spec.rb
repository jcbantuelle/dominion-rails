require 'spec_helper'

describe 'Highway' do
  let(:card_name) { 'highway' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +1 card, +1 action, and reduces card costs by $1' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(1)
      expect(@turn.global_discount).to eq(1)
      expect(@game_player.hand.count).to eq(1)
    end
  end
end
