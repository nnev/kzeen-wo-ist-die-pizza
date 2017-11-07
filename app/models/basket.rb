class Basket < ApplicationRecord
  has_many :orders

  def self.current
    # baskets submitted more than a day ago are not considered current
    Basket.all.order(created_at: :desc).where(['submitted_at > ? OR submitted_at IS NULL', 1.days.ago]).first
  end

  def editable?
    submitted_at.nil?
  end

  def r_branch
    @r_branch ||= Remote::Branch.new(branch_id: branch_id)
  end

  def self.current_or_create
    # TODO: not threadsafe
    self.current || Basket.create!(branch_id: Remote::Branch.main.branch_id)
  end
end
