require 'spec_helper'

describe 'Merchant Ship' do
  let(:card_name) { 'merchant_ship' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +$2' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
    end
  end

  describe '#duration' do
    include_context 'duration'

    it 'gives +$2' do
      @subject.next_turn
      expect(@game.current_turn.coins).to eq(2)
    end
  end

end
