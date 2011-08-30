module MediumCityResource
  def adjust_army_training_queues_by_population
    medium_city.adjust_army_training_queues_by_population if medium_city
  end

  def supply_food_for_armies
    return unless medium_city

    delta = city_food - medium_city.armies_food_consumption
    # not trigger callback :collect_tax
    self.update_attribute(:food, [delta, 0].max)
    medium_city.decrease_armies_amount_for_food if delta < 0

    medium_city.clean_food_consumption
  end

  def medium_city(reload = false)
    @medium_city = nil if reload
    @medium_city ||= MediumCity.find(city.id) if city.is_medium_city?
  end
end
