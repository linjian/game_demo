class Army < ActiveRecord::Base
  belongs_to :user
  belongs_to :medium_city, :foreign_key => "city_id"

  validates_numericality_of :amount,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  class << self
    # Set constants Army::Spearman::ARMY_TYPE etc.
    def const_missing(name)
      if name.to_s == 'ARMY_TYPE' && self.to_s =~ /^Army::/
        self.const_set(name, self.to_s.demodulize.upcase)
      else
        super
      end
    end
  end

  def specialize
    klass = self.class.const_get(army_type.capitalize)
    klass.find(self.id)
  end
end
