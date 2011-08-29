module Rspec
  module GameDemo
    module ArmyTrainingQueueSpecHelper
      def create_max_waiting_queues(city)
        queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
        (MediumCity.maximum_waiting_training_queue -
         city.waiting_training_queues.size).times do |i|
          city.army_training_queues.create(queue_attrs)
        end
        city.reload
      end

      def create_waiting_queue(city)
        queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
        city.army_training_queues.create(queue_attrs)
      end

      def create_in_training_queue(city)
        queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5,
                       :in_training => true, :start_training_time => Time.now.utc}
        city.army_training_queues.create(queue_attrs)
      end

      def clean_waiting_queuqs(city)
        city.waiting_training_queues.each(&:destroy)
      end
    end
  end
end
