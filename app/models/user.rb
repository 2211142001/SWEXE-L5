class User < ApplicationRecord
  has_many :tweets
  has_one :profile
end
