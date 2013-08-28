require 'spec_helper'

describe 'Fishing Village' do
  let(:card_name) { 'fishing_village' }

  describe '#play' do
    include_context 'play card'

    it 'gives +2 actions and +$1' do
      @subject.play_card
      @turn.reload
      expect(@turn.actions).to eq(2)
      expect(@turn.coins).to eq(1)
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +1 action and +$1' do
      @subject.next_turn
      expect(@game.current_turn.actions).to eq(2)
      expect(@game.current_turn.coins).to eq(1)
    end
  end

end
