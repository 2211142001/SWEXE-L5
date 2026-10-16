class User < ApplicationRecord
  has_many :tweets
  has_one :profile
  has_many :likes
  has_many :like_tweets, through: :likes, source: :tweet
end
