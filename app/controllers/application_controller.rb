class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery with: :exception

  COOKIE_NICK = '_hipsterpizza_nick'
  COOKIE_ADMIN = '_hipsterpizza_is_admin'

  before_action do
    @nick = cookies[COOKIE_NICK].presence&.strip
    @is_admin = cookies[COOKIE_ADMIN] == 'true'
  end

  before_action do
    avail = I18n.available_locales
    I18n.locale = http_accept_language.compatible_language_from(avail)
  end

  private

  def handle_err(err)
    reference = SecureRandom.hex
    Rails.logger.error('reference: ' << reference)
    Rails.logger.error(err.inspect)
    Rails.logger.error(err.backtrace.join("\n"))

    flash[:error] = t('unhandled_error', message: err.message.to_s, reference: reference).html_safe
  end
end
