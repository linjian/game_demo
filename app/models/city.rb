class City < ActiveRecord::Base
  MAXIMUM_PER_USER = 10

  belongs_to :user
end
