require 'spec_helper'

describe 'GamePlayer' do

  context 'has coin in hand' do
    let(:number_of_coin_cards_in_hand) { 3 }
    let(:game_player) { GamePlayer.create turn_order: 1 }

    before(:each) {
      cards_in_hand = []

      DEFAULT_IN_HAND.times do |i|
        cards_in_hand << double('PlayerCard', coin_card?: (i < number_of_coin_cards_in_hand))
      end

      game_player.player_cards.stub(:hand).and_return(cards_in_hand)
    }

    describe '.find_coin_in_hand' do
      it 'finds all coin in hand' do
        expect(game_player.find_coin_in_hand.count).to eq(number_of_coin_cards_in_hand)
      end
    end
  end


end