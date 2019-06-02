class AddUserAddressesToAddress < ActiveRecord::Migration[5.1]
  def change
    User.find_each do |user|
      user.addresses.create(
        zip: user.zip,
        city: user.city,
        state: user.state,
        address: user.address,
        user_id: user.id,
        nickname: "home"
      )
    end
  end
end
