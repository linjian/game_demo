module Rspec
  module GameDemo
    module ArmyTrainingQueueSpecHelper
      def create_max_waiting_queues(city)
        queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
        (MediumCity::MAXIMUM_WAITING_TRAINING_QUEUE -
         city.waiting_training_queues.size).times do |i|
          city.army_training_queues.create(queue_attrs)
        end
        city.reload
      end

      def create_training_queue(city)
        queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
        city.army_training_queues.create(queue_attrs)
      end
    end
  end
end
