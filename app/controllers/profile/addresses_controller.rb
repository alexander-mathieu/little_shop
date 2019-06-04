class Profile::AddressesController < ApplicationController
  before_action :require_reguser
  before_action :save_previous_uri, only: :new

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
      if session[:previous_uri] == cart_path
        session[:previous_uri] = nil
        redirect_to cart_path
      else
        redirect_to profile_addresses_path
      end
    else
      flash.now[:danger] = @address.errors.full_messages
      render :new
    end
  end

  def edit
    @address = Address.find(params[:id])
  end

  def update
    @address = Address.find(params[:id])

    if @address.update(address_params)
      current_user.reload

      flash[:success] = "Address updated."
      redirect_to profile_addresses_path
    else
      flash.now[:danger] = @address.errors.full_messages
      render :edit
    end
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

  def save_previous_uri
    session[:previous_uri] = URI(request.referer || '').path
  end
end
