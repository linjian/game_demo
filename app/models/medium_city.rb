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
  has_one :in_training_queue,         :foreign_key => "city_id",
    :class_name => "ArmyTrainingQueue",
    :dependent  => :destroy,
    :conditions => {:in_training => true}

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

  def get_army_info
    with_training do
      [:trained_army, :in_training, :waiting_training].inject({}) do |info, key|
        info.merge(key => self.send("#{key}_info"))
      end
    end
  end

  def with_training
    do_training
    yield
  end

  def trained_army_info
    [:spearman, :archer, :cavalry].inject({}) do |info, army|
      info.merge(army => self.send(army).try(:amount) || 0)
    end
  end

  def in_training_info
    return unless in_training_queue
    [:army_type, :amount,  :start_training_time,
     :training_spent_time, :training_remain_time].inject({}) do |info, method|
      info.merge(method => in_training_queue.send(method))
    end
  end

  def waiting_training_info
    waiting_training_queues.map do |queue|
      {:army_type => queue.army_type, :amount => queue.amount}
    end
  end

  def do_training
    return if army_training_queues.empty?

    army_training_queues.first.into_training(nil)

    [army_training_queues, nil].flatten.each_cons(2) do |queue, next_queue|
      queue.in_training? ? queue.finish_training(next_queue) : break
    end
  end

  def adjust_army_training_queues_by_population
    population = city_resource.population
    waiting_training_queues.each do |queue|
      if population > queue.amount
        population -= queue.amount
      elsif population > 0
        queue.update_attribute(:amount, population)
        population = 0
      else
        queue.destroy
      end
    end
  end
end
