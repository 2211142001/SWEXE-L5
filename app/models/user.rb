class User < ApplicationRecord
  has_many :tweets, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :like_tweets, through: :likes, source: :tweet
end
