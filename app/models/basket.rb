class Basket < ApplicationRecord
  has_many :orders

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
    arrival.present?
  end

  def duration
    return nil unless submitted? && arrived?
    dur = arrival - submitted
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

  private

  def sum_orders(orders)
    orders.map(&:sum).sum
  end
end
