# require_relative '../lib/sql_object'

class House < ApplicationModel
  # House.finalize!

  has_many :humen, class_name: :Human, foreign_key: :house_id
  has_many_through :cats, :humen, :cats
end