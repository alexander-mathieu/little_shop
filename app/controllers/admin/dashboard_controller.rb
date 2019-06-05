class Admin::DashboardController < Admin::BaseController
  def index
    @pending_orders = Order.pending_orders
    @packaged_orders = Order.packaged_orders
    @shipped_orders = Order.shipped_orders
    @cancelled_orders = Order.cancelled_orders
  end
end
