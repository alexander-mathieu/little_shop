class AddUserAddressestoAddress < ActiveRecord::Migration[5.1]
  def change
    User.find_each do |user|
      user.addresses.create(
        user_id: user.id,
        address: user.address
      )
    end
  end
end
