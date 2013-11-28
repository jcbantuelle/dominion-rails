class AddTypeToCard < ActiveRecord::Migration
  def change
    add_column :cards, :type, :string

    Card.reset_column_information

    Card.all.each do |c|
      c.update_attribute :type, c.name.classify
    end
  end
end
