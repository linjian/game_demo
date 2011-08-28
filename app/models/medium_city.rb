class MediumCity < City
  CITY_TYPE = "MEDIUM"
  MAXIMUM_WAITING_TRAINING_QUEUE = 5

  has_one :spearman,  :class_name => "Army::Spearman",
    :foreign_key  => "city_id",
    :dependent    => :destroy,
    :conditions   => {:army_type => Army::Spearman::ARMY_TYPE}
  has_one :archer,    :class_name => "Army::Archer",
    :foreign_key  => "city_id",
    :dependent    => :destroy,
    :conditions   => {:army_type => Army::Archer::ARMY_TYPE}
  has_one :cavalry,   :class_name => "Army::Cavalry",
    :foreign_key  => "city_id",
    :dependent    => :destroy,
    :conditions   => {:army_type => Army::Cavalry::ARMY_TYPE}

  has_many :army_training_queues,     :foreign_key => "city_id",
    :dependent  => :destroy
  has_many :waiting_training_queues,  :foreign_key => "city_id",
    :class_name => "ArmyTrainingQueue",
    :dependent  => :destroy,
    :conditions => {:in_training => false}

  def add_army_training_queue(queue_attrs)
    return false unless check_waiting_queue_count
    new_queue = self.army_training_queues.create(queue_attrs)
    errors.add(:army_training_queue, new_queue.errors.full_messages.join(". ")) if new_queue.invalid?
    new_queue.valid? ? new_queue : false
  end

  def check_waiting_queue_count
    hit_max = (waiting_training_queues.size >= MAXIMUM_WAITING_TRAINING_QUEUE)
    errors.add(:army_training_queue, "can only have at most #{MAXIMUM_WAITING_TRAINING_QUEUE}") if hit_max
    !hit_max
  end

  def waiting_training_population
    waiting_training_queues.inject(0) do |sum, queue|
      sum + queue.amount
    end
  end

  def cancel_army_training_queue(queue)
    if queue.in_training?
      errors.add(:army_training_queue, "can not be canceled because it's in training")
      false
    else
      queue.destroy
    end
  end
end
