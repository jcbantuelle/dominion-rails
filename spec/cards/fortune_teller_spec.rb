require 'spec_helper'

describe 'Fortune Teller' do
  let(:card_name) { 'fortune_teller' }
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
      @other_players.each do |player|
        5.times do |i|
          PlayerCard.create game_player: player, card: @card, state: 'deck', card_order: i
        end
      end
    end

    it 'discards other players revealed cards' do
      @subject.play_card
      @other_players.each do |player|
        expect(player.discard.count).to eq(5)
      end
    end

    context 'with a revealed curse' do
      it 'puts the curse on top of the deck' do
        curse = Card.find(Card.create(name: 'curse').id)
        @other_players.each do |player|
          PlayerCard.create game_player: player, card: curse, state: 'deck', card_order: 6
        end
        @subject.play_card
        @other_players.each do |player|
          expect(player.deck.count).to eq(1)
          expect(player.discard.count).to eq(5)
        end
      end
    end

    context 'with a revealed victory card' do
      it 'puts the victory card on top of the deck' do
        estate = Card.find(Card.create(name: 'estate').id)
        @other_players.each do |player|
          PlayerCard.create game_player: player, card: estate, state: 'deck', card_order: 6
        end
        @subject.play_card
        @other_players.each do |player|
          expect(player.deck.count).to eq(1)
          expect(player.discard.count).to eq(5)
        end
      end
    end
  end
end
