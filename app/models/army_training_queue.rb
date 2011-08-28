class ArmyTrainingQueue < ActiveRecord::Base
  belongs_to :user
  belongs_to :medium_city, :foreign_key => "city_id"

  validates_numericality_of :amount,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  validate :check_population

  before_create :set_user_id

  def check_population
    errors.add(:base, "not enough population") if not_enough_population?
  end

  def set_user_id
    self.user_id = medium_city.user.id
  end

  def not_enough_population?
    (medium_city.get_population - medium_city.waiting_training_population) < self.amount
  end
end
