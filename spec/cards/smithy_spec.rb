require 'spec_helper'

describe 'Smithy' do
  let(:card_name) { 'smithy' }

  include_context 'play card'

  describe '#play' do
    it 'gives +3 cards' do
      3.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      @turn.reload
      expect(@game_player.hand.count).to eq(3)
    end
  end
end
