# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_cards(cards, kingdom=false, treasure=false, victory=false, set=nil, supply=true)
  cards.each do |c|
    Card.where({name: c, kingdom: kingdom, treasure: treasure, victory: victory, set: set, supply: supply, type: c.classify}).first_or_create
  end
end

# Treasure Cards
cards = %w(copper silver gold potion platinum)
create_cards(cards, false, true, false)

# Outside Supply
cards = %w(hovel necropolis overgrown_estate madman mercenary)
create_cards(cards, false, false, false, nil, false)

# Spoils
cards = %w(spoils)
create_cards(cards, false, true, false, nil, false)

# Ruins
cards = %w(ruins abandoned_mine ruined_library ruined_market ruined_village survivors)
create_cards(cards)

# Victory Cards
cards = %w(estate duchy province colony)
create_cards(cards, false, false, true)

# Curse
cards = %w(curse)
create_cards(cards)

# Base set
cards = %w(village woodcutter gardens smithy council_room festival laboratory market witch adventurer moneylender chapel cellar bureaucrat militia thief throne_room moat chancellor library workshop feast mine remodel spy)
create_cards(cards, true, false, false, 'base')

# Intrigue
cards = %w(great_hall duke harem coppersmith conspirator shanty_town bridge courtyard pawn secret_chamber masquerade steward swindler wishing_well baron ironworks mining_village scout nobles minion saboteur torturer trading_post upgrade tribute)
create_cards(cards, true, false, false, 'intrigue')

# Seaside
cards = %w(cutpurse bazaar sea_hag treasure_map fishing_village caravan merchant_ship wharf tactician lighthouse outpost)
# embargo haven native_village pearl_diver ambassador lookout smugglers warehouse island navigator pirate_ship salvager explorer ghost_ship treasury
create_cards(cards, true, false, false, 'seaside')
#
# Alchemy
cards = %w(transmute vineyard apothecary herbalist scrying_pool university familiar philosophers_stone)
# alchemist golem apprentice possession
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
cards = %w(crossroads duchess fools_gold develop oasis oracle nomad_camp silk_road cache highway ill_gotten_gains scheme tunnel jack_of_all_trades noble_brigand spice_merchant trader cartographer embassy haggler inn mandarin margrave stables border_village farmland)
create_cards(cards, true, false, false, 'hinterlands')

# Dark Ages
cards = %w(poor_house vagrant sage bandit_camp rats death_cart marauder beggar squire forager hermit market_square storeroom urchin armory feodum fortress ironmonger procession scavenger band_of_misfits wandering_minstrel catacombs count counterfeit cultist graverobber junk_dealer mystic pillage rebuild rogue altar hunting_grounds knights)
create_cards(cards, true, false, false, 'dark_ages')

# Knights
cards = %w(dame_anna dame_josephine dame_molly dame_natalie dame_sylvia sir_martin sir_bailey sir_destry sir_michael sir_vander)
create_cards(cards)

# Guilds
# cards = %w(candlestick_maker stonemason doctor masterpiece advisor herald plaza taxman baker butcher journeyman merchant_guild soothsayer)
# create_cards(cards, true, false, false, 'guilds')
