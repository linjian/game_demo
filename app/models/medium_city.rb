class MediumCity < City
  CITY_TYPE = "MEDIUM"

  has_one :spearman,  :class_name => "Army::Spearman",
    :foreign_key => "city_id",
    :conditions => {:army_type => Army::Spearman::ARMY_TYPE}
  has_one :archer,    :class_name => "Army::Archer",
    :foreign_key => "city_id",
    :conditions => {:army_type => Army::Archer::ARMY_TYPE}
  has_one :cavalry,   :class_name => "Army::Cavalry",
    :foreign_key => "city_id",
    :conditions => {:army_type => Army::Cavalry::ARMY_TYPE}
end
