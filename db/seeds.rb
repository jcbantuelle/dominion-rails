# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_cards(cards, kingdom=false, treasure=false, victory=false, set=nil)
  Card.create(cards.map{|c| {name: c, kingdom: kingdom, treasure: treasure, victory: victory, set: set} })
end

# Treasure Cards
cards = %w(copper silver gold)
create_cards(cards, false, true, false)

# Victory Cards
cards = %w(estate duchy province)
create_cards(cards, false, false, true)

# Curse
cards = %w(curse)
create_cards(cards)

# Base Set Kingdom
cards = %w(moat chapel cellar chancellor village woodcutter workshop bureaucrat feast gardens militia moneylender remodel smithy spy thief throne_room council_room festival laboratory library market mine witch adventurer)
create_cards(cards, true, false, false, 'base')
