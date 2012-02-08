class Permission < ActiveRecord::Base
  belongs_to  :tracking
  belongs_to  :user
end
