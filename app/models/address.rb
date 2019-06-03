class Address < ApplicationRecord
  belongs_to :user
  has_many :orders

  validates_presence_of :nickname, :address, :city, :state, :zip
  validates_uniqueness_of :nickname, scope: [:user_id]
end
