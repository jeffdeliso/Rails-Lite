# require_relative '../lib/sql_object'

class House < ApplicationModel
  # House.finalize!

  has_many :users, 
    class_name: :User, 
    foreign_key: :house_id
    
  has_many :cats,
    through: :users,
    source: :cats
end