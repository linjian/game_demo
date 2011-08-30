class MediumCity < City
  extend ArmyAssociations::City

  has_one_army :spearman
  has_one_army :archer
  has_one_army :cavalry

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

  config_class_methods :medium_city_type, :maximum_waiting_training_queue

  def armies
    [spearman, archer, cavalry].compact
  end

  def armies_food_consumption
    armies.sum(&:get_food)
  end

  def clean_food_consumption
    armies.each {|army| army.update_attributes(:food => 0)}
  end

  def decrease_armies_amount_for_food
    # not trigger callback :set_food
    armies.each {|army| army.update_attribute(:amount, (army.amount * army.remain_rate).to_i)}
  end

  def add_army_training_queue(queue_attrs)
    return false unless check_waiting_queue_count
    new_queue = self.army_training_queues.create(queue_attrs)
    errors.add(:army_training_queue, new_queue.errors.full_messages.join(". ")) if new_queue.invalid?
    new_queue.valid? ? new_queue : false
  end

  def check_waiting_queue_count
    hit_max = (waiting_training_queues.size >= self.class.maximum_waiting_training_queue)
    errors.add(:army_training_queue, "can only have at most #{self.class.maximum_waiting_training_queue}") if hit_max
    !hit_max
  end

  def waiting_training_population
    waiting_training_queues.to_a.sum(&:amount)
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
    mark_training_queues_by_population(city_resource.population)
    clean_training_queues_by_population
  end

  def mark_training_queues_by_population(population)
    waiting_training_queues.each do |queue|
      population -= queue.amount
      queue.amount += population if population < 0
    end
  end

  def clean_training_queues_by_population
    waiting_training_queues.each do |queue|
      next unless queue.amount_changed?
      if queue.amount > 0
        # not trigger callback :set_food
        queue.update_attribute(:amount, queue.amount)
      else
        queue.destroy
      end
    end
  end
end
