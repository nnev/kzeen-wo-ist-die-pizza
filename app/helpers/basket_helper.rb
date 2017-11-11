module BasketHelper
  def time(t)
    return t.strftime('%Y-%m-%d %H:%M') unless t > 12.hours.ago

    timestamp = content_tag(:time, t.strftime('%H:%M'), datetime: t)

    key = t < Time.now ? 'past' : 'future'
    relative = t('time.' + key, date: time_ago_in_words(t))
    ago = content_tag(:span, relative, class: 'text-muted')

    timestamp << ago
  end
end
