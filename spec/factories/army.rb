FactoryGirl.define do
  factory :spearman, :class => Army::Spearman do
    association :medium_city, :factory => :medium_city
    association :user,        :factory => :user_1
    army_type 'SPEARMAN'
    amount 1
  end

  factory :archer, :class => Army::Archer do
    association :medium_city, :factory => :medium_city
    association :user,        :factory => :user_1
    army_type 'ARCHER'
    amount 1
  end

  factory :cavalry, :class => Army::Cavalry do
    association :medium_city, :factory => :medium_city
    association :user,        :factory => :user_1
    army_type 'CAVALRY'
    amount 1
  end
end
