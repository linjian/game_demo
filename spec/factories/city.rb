FactoryGirl.define do
  factory :city_1, :class => City do
    association :user, :factory => :user_1
    area_left_value   100
    area_bottom_value 100
  end

  factory :medium_city, :class => MediumCity do
    association :user, :factory => :user_1
    area_left_value   10000
    area_bottom_value 10000
    city_type 'MEDIUM'
  end
end
