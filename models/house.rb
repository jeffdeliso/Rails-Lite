# require_relative '../lib/sql_object'

class House < ApplicationModel
  # House.finalize!

  has_many :users
    
  has_many :cats,
    through: :users,
    source: :cats
end