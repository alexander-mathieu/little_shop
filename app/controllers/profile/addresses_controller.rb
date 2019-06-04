class Profile::AddressesController < ApplicationController
  before_action :require_reguser

  def index
    user = current_user
    @addresses = user.addresses
  end

  def new
    @address = Address.new
  end

  def create
    user = current_user
    @address = user.addresses.new(address_params)

    if @address.save
      flash[:success] = "Address added!"
      redirect_to profile_addresses_path
    else
      flash.now[:danger] = @address.errors.full_messages
      render :new
    end
  end

  def edit

  end

  def update

  end

  def destroy
    address = Address.find(params[:id])
    address.destroy
    current_user.reload

    flash[:success] = "Address deleted."
    redirect_to profile_addresses_path
  end

  private

  def address_params
    params.require(:address).permit(:address, :city, :state, :zip, :nickname)
  end
end
