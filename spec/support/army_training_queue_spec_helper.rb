module Rspec
  module GameDemo
    module ArmyTrainingQueueSpecHelper
      def create_max_waiting_queues(city)
        (MediumCity.maximum_waiting_training_queue -
         city.waiting_training_queues.size).times do
          city.army_training_queues.create(queue_attrs)
        end
        city.reload
      end

      def create_waiting_queue(city)
        city.army_training_queues.create(queue_attrs)
      end

      def create_in_training_queue(city)
        attrs = queue_attrs.merge(:in_training => true, :start_training_time => Time.now.utc)
        city.army_training_queues.create(attrs)
      end

      def clean_waiting_queuqs(city)
        city.waiting_training_queues.each(&:destroy)
      end

      def queue_attrs
        {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
      end

      def get_training_time(*training_queues)
        delta = training_queues.last.is_a?(ActiveSupport::Duration) ? training_queues.pop : 2.minutes
        training_queues.first.start_training_time + training_queues.sum(&:total_training_duration) + delta
      end
    end
  end
end
