class Dashboard::DashboardController < Dashboard::BaseController
  def index
    @merchant = current_user
    @pending_orders = Order.pending_orders_for_merchant(current_user.id)
    @items_without_pictures = @merchant.items_without_pictures
  end
end
