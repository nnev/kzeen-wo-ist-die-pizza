module SafeBroadcast
  extend ActiveSupport::Concern

  # eat any errors that appear during broadcast in order to not break the
  # actual action being carried out
  def safe_broadcast
    Thread.new do
      begin
        yield
      rescue => e
        Rails.logger.error "Broadcast failed: #{e.message}\n#{e.inspect}\n#{e.backtrace}"
      ensure
        Rails.logger.flush
      end
    end
  end
end
