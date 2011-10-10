FactoryGirl.define do
  factory :army_training_queue_1, :class => ArmyTrainingQueue do
    association :medium_city, :factory => :medium_city
    association :user,        :factory => :user_1
    army_type 'SPEARMAN'
    amount 1
  end
end
