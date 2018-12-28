require_relative '../lib/sql_object'

class House < SQLObject
  House.finalize!

  has_many(:humen, class_name: :Human, foreign_key: :house_id)
  has_many(:cats, class_name: :Cat, foreign_key: :owner_id)
end