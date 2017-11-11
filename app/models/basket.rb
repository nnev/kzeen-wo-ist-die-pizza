class Basket < ApplicationRecord
  has_many :orders

  scope :with_duration, -> { where.not(arrived_at: nil, submitted_at: nil, cancelled: true) }

  def self.current
    # baskets submitted more than a day ago are not considered current
    Basket.all.order(created_at: :desc).where(['submitted_at > ? OR submitted_at IS NULL', 1.days.ago]).first
  end

  def self.current_or_create
    # TODO: not threadsafe
    self.current || Basket.create!(branch_id: Remote::Branch.main.branch_id)
  end

  def editable?
    submitted_at.nil? && !cancelled?
  end

  def submitted?
    submitted_at.present?
  end

  def arrived?
    arrived_at.present?
  end

  def duration
    return nil unless submitted? && arrived?
    dur = arrived_at - submitted_at
    return nil if dur < 0
    dur
  end

  def duration_per_euro
    return nil if sum == 0
    duration.to_f/sum
  end

  def r_branch
    @r_branch ||= Remote::Branch.new(branch_id: branch_id)
  end

  def sum
    sum_orders(orders)
  end

  def sum_paid
    sum_orders(orders.paid)
  end

  def sum_unpaid
    sum_orders(orders.unpaid)
  end

  def estimate
    dur_per_euro = Basket.with_duration.where.not(id: self.id).map(&:duration_per_euro).compact
    return nil, 0 if dur_per_euro.empty?

    avg = dur_per_euro.sum.to_f / dur_per_euro.size.to_f
    return (avg * sum).round, dur_per_euro.size
  end

  private

  def sum_orders(orders)
    orders.map(&:sum).sum
  end
end
