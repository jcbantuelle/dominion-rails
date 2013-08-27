require 'spec_helper'

describe 'Fairgrounds' do
  let(:card_name) { 'fairground' }

  describe '#value' do

    include_context 'victory card'

    it 'is worth 2 points per 5 uniquely named cards' do
      deck = []
      unique_card_names = %w(adventurer caravan city conspirator coppersmith council_room crossroad cutpurse fairground familiar farming_village festival)
      unique_card_names.each do |name|
        card = Card.create name: name
        deck << PlayerCard.create(game_player: @game_player, card_id: card.id, state: 'deck')
      end

      expect(@card.value(deck)).to eq(4)
    end
  end

end
