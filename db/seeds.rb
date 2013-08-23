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

# Base set
cards = %w(village woodcutter gardens smithy council_room festival laboratory market witch adventurer moneylender)
# moat chapel cellar chancellor workshop bureaucrat feast militia remodel spy thief throne_room library mine
create_cards(cards, true, false, false, 'base')

# Intrigue
cards = %w(great_hall duke harem coppersmith conspirator)
# shanty_town bridge
# courtyard pawn secret_chamber masquerade steward swindler wishing_well baron ironworks mining_village scount minion saboteur torturer trading_post tribute upgrade nobles
create_cards(cards, true, false, false, 'intrigue')

# Seaside
cards = %w(cutpurse bazaar)
# lighthouse fishing_village caravan sea_hag treasure_map merchant_ship outpost tactician wharf
# embargo haven native_village pearl_diver ambassador lookout smugglers warehouse island navigator pirate_ship salvager explorer ghost_ship treasury
create_cards(cards, true, false, false, 'seaside')
#
# Alchemy
cards = %w(vineyard familiar)
# philosophers_stone possession
# transmute apothecary herbalist scrying_pool university alchemist golem apprentice
create_cards(cards, true, false, false, 'alchemy')
#
# Prosperity
cards = %w(monument workers_village venture bank)
# quarry grand_market talisman city hoard peddler
# loan trade_route watchtower bishop contraband counting_house mint mountebank rabble royal_seal vault goons expand forge kings_court
create_cards(cards, true, false, false, 'prosperity')
#
# Cornucopia
# cards = %w()
# hunting_party fairgrounds fortune_teller menagerie farming_village harvest
# hamlet horse_traders remake tournament young_witch horn_of_plenty jester
# bag_of_gold diadem followers princess trusty_steed
# create_cards(cards, true, false, false, 'cornucopia')
#
# Hinterlands
# cards = %w()
# crossroads nomad_camp silk_road cache highway
# duchess fools_gold develop oasis oracle scheme tunnel jack_of_all_trades noble_brigand spice_merchant trader cartographer embassy haggler ill_gotten_gains inn mandarin margrave stables border_village farmland
# create_cards(cards, true, false, false, 'hinterlands')
