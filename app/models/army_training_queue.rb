class ArmyTrainingQueue < ActiveRecord::Base
  belongs_to :user
  belongs_to :medium_city, :foreign_key => "city_id"

  validates_presence_of :city_id, :user_id, :army_type
  validates :amount,
    :numericality => {:greater_than => 0,
                      :only_integer => true}

  validate :check_population

  before_validation :set_user_id

  def check_population
    errors.add(:base, "not enough population") if not_enough_population?
  end

  def set_user_id
    self.user_id = medium_city.user_id
  end

  def not_enough_population?
    (medium_city.get_population - medium_city.waiting_training_population) < self.amount
  end

  def training_spent_time
    return unless in_training?
    (Time.now.utc - start_training_time).to_i
  end

  def training_remain_time
    return unless in_training?
    total_training_duration - training_spent_time
  end

  def end_training_time
    start_training_time + total_training_duration
  end

  def army_class
    Army.const_get(army_type.capitalize)
  end

  def finish?
    training_remain_time <= 0
  end

  def finish_training(next_queue)
    return unless self.finish?

    add_amount_to_army_for_training
    cost_gold_for_training
    self.destroy
    next_queue.into_training(self) if next_queue
  end

  def add_amount_to_army_for_training
    association = army_type.downcase
    army = medium_city.send(association) || medium_city.send("create_#{association}")
    army.amount += amount
    army.save
  end

  def cost_gold_for_training
    self.medium_city.city_resource.reload
    self.medium_city.city_resource.gold -= total_gold_cost
    self.medium_city.city_resource.save
  end

  def into_training(previous_queue)
    return if self.in_training?

    start_training_time = previous_queue ? previous_queue.end_training_time : Time.now.utc
    self.update_attributes(:in_training => true, :start_training_time => start_training_time)

    self.medium_city.city_resource.population -= self.amount
    self.medium_city.city_resource.save
  end

  def total_gold_cost
    army_class.gold_cost * amount
  end

  def total_training_duration
    army_class.training_duration * amount
  end
end
