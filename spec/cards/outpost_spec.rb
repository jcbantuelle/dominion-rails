require 'spec_helper'

describe 'Outpost' do

  let(:card_name) { 'outpost' }
  include_context 'setup'

  describe '#duration' do
    include_context 'duration'

    it 'gives an extra turn with a 3 card hand' do
      PlayerCard.create game_player: @game_player, card: @card, state: 'duration'
      4.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.next_turn
      expect(@game_player.hand.count).to eq(3)
    end
  end

end
