class OrderController < ApplicationController
  before_action do
    @basket = Basket.current_or_create
  end

  before_action :find_or_create_order
  before_action :check_permissions
  before_action :ensure_basket_editable, except: :toggle_paid

  def show
  end

  def destroy
    @order.destroy!
    redirect_to :root
  end

  def item_create
    @order.add_item(permitted_params)
    save_items
  end

  def item_destroy
    @order.destroy_item(params[:index].to_i)
    save_items
  end

  def item_update
    @order.update_item(params[:index].to_i, permitted_params)
    save_items
  end

  def show_basket
    render partial: 'show_basket'
  end

  def toggle_paid
    @order.toggle(:paid).save
    if request.xhr?
      return head :ok
    else
      key = "order.controller.toggle_paid.#{@order.paid? ? 'is' : 'not'}_paid"
      flash[:info] = t(key, nick: @order.nick.possessive)
      return redirect_to :root
    end
  end

  private

  def save_items
    if @order.save
      show_basket
    else
      render status: :bad_request, json: @order.errors
    end
  end

  def find_or_create_order
    # prefer order_id param from URL over auto-guessing via nick
    @order = Order.find(params[:order_id]) if params[:order_id]
    @order ||= Order.find_or_create_by(nick: @nick, basket: @basket)
  end

  def permitted_params
    params.permit(:product_id, :size, extra_ingred: [], basic_ingred: {})
  end

  def check_permissions
    return if @is_admin
    return if @order.new_record?
    return if @order.nick == @nick

    flash[:warn] = I18n.t('order.controller.admin_required')
    redirect_to vanity_basket_path
  end

  def ensure_basket_editable
    if @basket.cancelled?
      flash[:error] = I18n.t('order.controller.cancelled')
      redirect_to vanity_basket_path
    elsif @basket.submitted?
      prefix = 'order.controller.already_submitted'
      flash[:error] = I18n.t("#{prefix}.main")
      redirect_to vanity_basket_path
    end
  end
end
