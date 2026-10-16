class TopController < ApplicationController
  def main
    @tweets = Tweet.all
  end

  def signup
    @user = User.new
  end

  def signin
    @user = User.new
  end
end
