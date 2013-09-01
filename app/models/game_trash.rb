class GameTrash < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  def name
    card.name
  end

  def type_class
    card.type_class
  end

  def json
    {
      id: id,
      name: name,
      type_class: type_class,
      title: name.titleize
    }
  end
end
