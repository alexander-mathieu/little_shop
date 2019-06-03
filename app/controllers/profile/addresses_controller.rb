class Profile::AddressesController < ApplicationController
  before_action :require_reguser

  def index
    user = current_user
    @addresses = user.addresses
  end
end
