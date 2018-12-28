# require_relative '../lib/sql_object'

class Cat < SQLObject
  # Cat.finalize!
  validates :name, presence: true, class: String, uniqueness: true
  validates :owner_id, presence: true

  belongs_to :owner, class_name: :Human, foreign_key: :owner_id
  has_one_through :house, :owner, :house
end