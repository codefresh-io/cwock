class Note < ActiveRecord::Base
  validates :taken_at, :presence => true
end
