# require_relative '../lib/sql_object'

class Cat < ApplicationModel
  # Cat.finalize!
  validates :name, presence: true, class: String, uniqueness: true
  # validates :owner_id, presence: true

  belongs_to :owner,
    class_name: :User
    
  has_one :house,
    through: :owner,
    source: :house
end 