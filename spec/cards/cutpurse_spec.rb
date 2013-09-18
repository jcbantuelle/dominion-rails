require 'spec_helper'

describe 'Cutpurse' do
  let(:card_name) { 'cutpurse' }
  include_context 'setup'
  include_context 'urchin card'

  describe '#play' do
    include_context 'play card'
    it 'gives +$2' do
      @subject.play_card
      @turn.reload
      expect(@turn.coins).to eq(2)
    end

    include_context 'other players'

    before(:each) do
      @copper = Card.find(Card.create(name: 'copper'))
    end

    context 'other players have copper in hand' do
      it 'discards copper from other players hands' do
        @other_players.each do |player|
          2.times do
            PlayerCard.create game_player: player, card: @copper, state: 'hand'
          end
        end
        @subject.play_card
        @other_players.each do |player|
          expect(player.hand.count).to eq(1)
          expect(player.discard.count).to eq(1)
        end
      end
    end

    context 'other players do not have copper in hand' do
      it 'does nothing' do
        @other_players.each do |player|
          2.times do
            PlayerCard.create game_player: player, card: @card, state: 'hand'
          end
        end
        @subject.play_card
        @other_players.each do |player|
          expect(player.hand.count).to eq(2)
          expect(player.discard.count).to eq(0)
        end
      end
    end
  end
end
