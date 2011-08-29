class Army < ActiveRecord::Base
  TURNOVER_RATE = 0.1

  belongs_to :user
  belongs_to :medium_city, :foreign_key => "city_id"

  validates_numericality_of :food,
    :greater_than_or_equal_to => 0
  validates_numericality_of :amount,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  before_create :set_army_type, :set_user_id
  before_save :set_food

  class << self
    def gold_cost
      self.const_get(:GOLD_COST)
    end

    def training_duration
      self.const_get(:TRAINING_DURATION)
    end

    def food_consumption
      self.const_get(:FOOD_CONSUMPTION)
    end

    def food_consumption_rate
      food_consumption.to_f / 1.hour
    end

    # Set constants Army::Spearman::ARMY_TYPE etc.
    def const_missing(name)
      if name.to_s == 'ARMY_TYPE' && self.to_s =~ /^Army::/
        self.const_set(name, self.to_s.demodulize.upcase)
      else
        super
      end
    end
  end

  def set_army_type
    self.army_type = self.class.const_get(:ARMY_TYPE)
  end

  def set_user_id
    self.user_id = self.medium_city.user_id if self.medium_city
  end

  def set_food(force = false)
    if force || amount_changed?
      now = Time.now.utc
      self.food = calculate_food(now)
      self.food_updated_time = now
    end
  end

  def get_food
    set_food(true)
    self.save if self.changed?
    self.food.to_i
  end

  def specialize
    klass = self.class.const_get(army_type.capitalize)
    klass.find(self.id)
  end

  def calculate_food(now)
    duration = now - (food_updated_time || now)
    amount_was * duration * self.class.food_consumption_rate + self.food
  end

  def remain_rate
    1 - TURNOVER_RATE
  end
end
