Factory.preload do
  factory(:user_1) { Factory(:user_1) }

  factory(:city_1)      { Factory(:city_1,      :user => users(:user_1)) }
  factory(:medium_city) { Factory(:medium_city, :user => users(:user_1)) }

  factory(:spearman) { Factory(:spearman, :user => users(:user_1), :medium_city => medium_cities(:medium_city)) }
  factory(:archer)   { Factory(:archer,   :user => users(:user_1), :medium_city => medium_cities(:medium_city)) }
  factory(:cavalry)  { Factory(:cavalry,  :user => users(:user_1), :medium_city => medium_cities(:medium_city)) }

  factory(:army_training_queue_1) { Factory(:army_training_queue_1,
                                            :user => users(:user_1),
                                            :medium_city => medium_cities(:medium_city)) }
end
