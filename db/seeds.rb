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
cards = %w(copper silver gold potion platinum)
create_cards(cards, false, true, false)

# Victory Cards
cards = %w(estate duchy province colony)
create_cards(cards, false, false, true)

# Curse
cards = %w(curse)
create_cards(cards)

# Base Kingdom Set
#cards = %w(moat chapel cellar chancellor village woodcutter workshop bureaucrat feast gardens militia moneylender remodel smithy spy thief throne_room council_room festival laboratory library market mine witch adventurer)
cards = %w(village woodcutter gardens smithy council_room festival laboratory market witch adventurer)
create_cards(cards, true, false, false, 'base')

# Intrigue Kingdom Set
#cards = %w(coppersmith great_hall duke harem)
cards = %w(great_hall duke harem)
create_cards(cards, true, false, false, 'intrigue')

# Seaside Kingdom Set
cards = %w(cutpurse bazaar)
create_cards(cards, true, false, false, 'seaside')
#
## Alchemy Kingdom Set
cards = %w(vineyard familiar)
create_cards(cards, true, false, false, 'alchemy')
#
## Prosperity Kingdom Set
cards = %w(monument workers_village venture)
# quarry grand_market bank)
create_cards(cards, true, false, false, 'prosperity')
#
## Cornucopia Kingdom Set
#cards = %w(hunting_party fairgrounds)
#create_cards(cards, true, false, false, 'cornucopia')
