# The TimeTracker class works as an extension to the Basket model and provides
# mostly convenience wrappers around a Basket’s delivery estimate function. It
# caches results.
class TimeTracker
  def initialize(basket)
    @basket = basket
    @estimate_in_seconds, @samples = basket.estimate
  end

  # returns Time object with the estimated arrival date
  def estimate
    submitted_at + @estimate_in_seconds
  end

  def estimate_percent
    rel_estimate.to_f / rel_max.to_f * 100.0
  end

  # returns formatted time of arrival, optionally accepting a strftime parameter
  # if the format needs to be something else.
  def estimate_arrival(strftime = '%H:%M')
    estimate.in_time_zone('Europe/Berlin').strftime(strftime)
  end

  def overdue?
    now > estimate
  end

  def overdue_percent
    duration = overdue? ? rel_now - rel_estimate : 0
    duration.to_f / rel_max.to_f * 100.0
  end

  def overdue_minutes
    return 0 unless overdue?
    ((now - estimate) / 60.0).round
  end

  def togo_minutes
    return '?' if overdue?
    ((estimate - now) / 60.0).round
  end

  def now_percent
    rel_now.to_f / rel_max.to_f * 100.0
  end

  def undue_percent
    if overdue?
      estimate_percent
    else
      now_percent
    end
  end

  attr_reader :samples

  private

  def max
    if arrived?
      [estimate, arrived_at].max
    else
      [estimate, now].max
    end
  end

  # XXX: if the order has not yet arrived, this really is now. Once the
  # order arrives, 'now' is fixed to the arrival date.
  def now
    if arrived?
      arrived_at
    else
      Time.now
    end
  end

  def method_missing(func, *args)
    if func.to_s.start_with?('rel_')
      abs = self.send(func.to_s[4..-1].to_sym, *args)
      return abs - submitted_at
    end

    @basket.send(func, *args)
  end
end

