require 'spec_helper'

describe 'Council Room' do
  let(:card_name) { 'council_room' }
  include_context 'setup'

  describe '#play' do
    include_context 'play card'
    it 'gives +4 cards' do
      5.times do
        PlayerCard.create game_player: @game_player, card: @card, state: 'deck'
      end
      @subject.play_card
      @turn.reload
      expect(@game_player.hand.count).to eq(4)
    end

    include_context 'other players'
    it 'gives +1 card to all other players' do
      @other_players.each do |player|
        2.times do
          PlayerCard.create game_player: player, card: @card, state: 'deck'
        end
      end
      @subject.play_card
      @other_players.each do |player|
        expect(player.hand.count).to eq(1)
      end
    end
  end
end
