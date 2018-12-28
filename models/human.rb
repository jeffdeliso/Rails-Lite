# require_relative '../lib/sql_object'

class Human < ApplicationModel
  # Human.finalize!

  belongs_to :house, class_name: :House, foreign_key: :house_id
  has_many :cats, class_name: :Cat, foreign_key: :owner_id
end