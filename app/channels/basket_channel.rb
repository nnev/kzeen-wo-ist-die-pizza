class BasketChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber of this channel.
  def subscribed
    stream_for "basket_#{params[:basket_id]}"
  end
end
