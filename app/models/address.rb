class Address < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :destroy

  validates_presence_of :nickname, :address, :city, :state, :zip
  validates_uniqueness_of :nickname, scope: [:user_id]

  def not_ordered?
    orders.where(status: [1, 2]).empty?
  end
end
