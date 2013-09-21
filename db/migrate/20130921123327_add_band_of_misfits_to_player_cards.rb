class AddBandOfMisfitsToPlayerCards < ActiveRecord::Migration
  def change
    add_column :player_cards, :band_of_misfits, :boolean, default: false
  end
end
