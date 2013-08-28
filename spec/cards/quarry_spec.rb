require 'spec_helper'

describe 'Quarry' do
  let(:card_name) { 'quarry' }

  describe '#play' do
    include_context 'play card'

    it 'gives +$1 and reduces action card costs by $2' do
      @subject.play_card
      @turn.reload
      expect(@turn.phase).to eq('treasure')
      expect(@turn.action_discount).to eq(2)
      expect(@turn.coins).to eq(1)
    end
  end
end
