require 'spec_helper'

describe 'Hoard' do
  let(:card_name) { 'hoard' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'

    it 'gives +$2 and gains a gold when buying a victory card' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.hoards).to eq(1)
      expect(@turn.coins).to eq(2)
    end
  end
end
