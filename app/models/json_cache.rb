require 'net/http'

class JsonCache < ApplicationRecord
  def self.get(path)
    raise 'Path must not start with /' if path.start_with?('/')

    url = Rails.application.config.shop_url + path

    c = ::JsonCache.find_or_create_by(url: url)
    return JSON.parse(c.json) if c && c.json.present?

    raw = ::Net::HTTP.get(URI.parse(url))
    # check it's valid before we cache
    parsed = JSON.parse(raw)
    c.json = raw
    c.save!

    parsed
  end
end
