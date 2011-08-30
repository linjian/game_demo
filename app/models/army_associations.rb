module ArmyAssociations
  module City
    def has_one_army(army)
      klass = army.to_s.capitalize
      has_one army,  :class_name => "Army::#{klass}",
        :foreign_key  => "city_id",
        :dependent    => :destroy,
        :conditions   => {:army_type => Army.const_get("#{klass}").const_get("ARMY_TYPE")}
    end
  end
end
