# require_relative '../lib/sql_object'

class Cat < ApplicationModel
  # Cat.finalize!
  validates :name, presence: true, class: String, uniqueness: true
  validates :owner_id, presence: true

  belongs_to :owner,
    class_name: :User,
    foreign_key: :owner_id
    
  has_one :house,
    through: :owner,
    source: :house
end 