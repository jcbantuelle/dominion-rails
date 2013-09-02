# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_cards(cards, kingdom=false, treasure=false, victory=false, set=nil)
  cards.each do |c|
    Card.where({name: c, kingdom: kingdom, treasure: treasure, victory: victory, set: set}).first_or_create
  end
end

# Treasure Cards
cards = %w(copper silver gold potion platinum spoils)
create_cards(cards, false, true, false)

# Victory Cards
cards = %w(estate duchy province colony)
create_cards(cards, false, false, true)

# Curse
cards = %w(curse)
create_cards(cards)

# Base set
cards = %w(village woodcutter gardens smithy council_room festival laboratory market witch adventurer moneylender chapel cellar bureaucrat militia thief throne_room moat chancellor library workshop feast)
# remodel spy mine
create_cards(cards, true, false, false, 'base')

# Intrigue
cards = %w(great_hall duke harem coppersmith conspirator shanty_town bridge)
# courtyard pawn secret_chamber masquerade steward swindler wishing_well baron ironworks mining_village scount minion saboteur torturer trading_post tribute upgrade nobles
create_cards(cards, true, false, false, 'intrigue')

# Seaside
cards = %w(cutpurse bazaar sea_hag treasure_map fishing_village caravan merchant_ship wharf tactician lighthouse outpost)
# embargo haven native_village pearl_diver ambassador lookout smugglers warehouse island navigator pirate_ship salvager explorer ghost_ship treasury
create_cards(cards, true, false, false, 'seaside')
#
# Alchemy
cards = %w(vineyard familiar philosophers_stone)
# possession
# transmute apothecary herbalist scrying_pool university alchemist golem apprentice
create_cards(cards, true, false, false, 'alchemy')
#
# Prosperity
cards = %w(monument workers_village venture bank grand_market quarry city peddler hoard talisman kings_court)
# loan trade_route watchtower bishop contraband counting_house mint mountebank rabble royal_seal vault goons expand forge
create_cards(cards, true, false, false, 'prosperity')
#
# Cornucopia
cards = %w(hunting_party fairgrounds menagerie harvest farming_village fortune_teller)
# hamlet horse_traders remake tournament young_witch horn_of_plenty jester
# bag_of_gold diadem followers princess trusty_steed
create_cards(cards, true, false, false, 'cornucopia')
#
# Hinterlands
cards = %w(crossroads nomad_camp silk_road cache highway)
# duchess fools_gold develop oasis oracle scheme tunnel jack_of_all_trades noble_brigand spice_merchant trader cartographer embassy haggler ill_gotten_gains inn mandarin margrave stables border_village farmland
create_cards(cards, true, false, false, 'hinterlands')

# Dark Ages
cards = %w(poor_house vagrant sage bandit_camp)
create_cards(cards, true, false, false, 'dark_ages')
