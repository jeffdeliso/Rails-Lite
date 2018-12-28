# require_relative '../lib/sql_object'

class Cat < SQLObject
  # Cat.finalize!
  
  belongs_to :owner, class_name: :Human, foreign_key: :owner_id
  has_one_through :house, :owner, :house
end