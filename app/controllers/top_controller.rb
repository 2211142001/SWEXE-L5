class TopController < ApplicationController
  before_action :redirect_if_signed_in, only: [ :signup, :signup_post, :signin, :signin_post ]
  before_action :redirect_if_signed_out, only: [ :signout, :create_tweet, :delete_tweet, :like_tweet, :unlike_tweet ]

  def main
    @tweets = Tweet.all
  end

  def signup
    @user = User.new
  end

  def signup_post
    if User.exists?(uid: user_params[:uid])
      @user = User.new
      flash[:message] = "このIDは既に使用されています"
      render :signup, status: :unprocessable_entity
      return
    end

    user = User.new(user_params)
    user.pass = BCrypt::Password.create(user_params[:pass])

    if user.save
      flash[:message] = "ユーザー登録に成功しました"
      session[:user_id] = user.id
      redirect_to root_path
    else
      @user = User.new
      flash[:message] = "ユーザー登録に失敗しました"
      render :signup, status: :unprocessable_entity
    end
  end

  def signin
    @user = User.new
  end

  def signin_post
    user = User.find_by(uid: user_params[:uid])
    if user && BCrypt::Password.new(user.pass) == user_params[:pass]
      session[:user_id] = user.id
      flash[:message] = "ログインに成功しました"
      redirect_to root_path
    else
      @user = User.new
      flash[:message] = "IDまたはパスワードが正しくありません"
      render :signin, status: :unprocessable_entity
    end
  end

  def signout
    session[:user_id] = nil
    flash[:message] = "ログアウトしました"
    redirect_to root_path
  end

  def create_tweet
    user = User.find(session[:user_id])
    tweet = Tweet.new(message: params[:message])
    user.tweets << tweet

    if tweet.save
      flash[:message] = "ツイートしました"
      redirect_to root_path
    else
      flash[:message] = "ツイートに失敗しました"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def delete_tweet
    tweet = Tweet.find(params[:id])
    if tweet.user_id != session[:user_id]
      flash[:message] = "このツイートは削除できません"
      redirect_to root_path, status: :forbidden
      return
    end

    if tweet.destroy
      flash[:message] = "ツイートを削除しました"
      redirect_to root_path
    else
      flash[:message] = "ツイートの削除に失敗しました"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def like_tweet
    user = User.find(session[:user_id])
    liked_tweet = user.like_tweets.find_by(id: params[:id])
    if liked_tweet
      flash[:message] = "このツイートは既にいいねされています"
      redirect_to root_path, status: :unprocessable_entity
      return
    end

    tweet = Tweet.find(params[:id])
    user.like_tweets << tweet

    if user.save
      flash[:message] = "ツイートをいいねしました"
      redirect_to root_path
    else
      flash[:message] = "ツイートのいいねに失敗しました"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def unlike_tweet
    user = User.find(session[:user_id])
    tweet = Tweet.find(params[:id])
    liked_tweet = user.like_tweets.find_by(id: tweet.id)

    if liked_tweet
      user.like_tweets.delete(liked_tweet)
      flash[:message] = "ツイートのいいねを解除しました"
      redirect_to root_path
    else
      flash[:message] = "このツイートはいいねされていません"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:uid, :pass)
  end

  def redirect_if_signed_in
    if session[:user_id]
      redirect_to root_path, notice: "ログイン済みです"
    end
  end

  def redirect_if_signed_out
    if session[:user_id].nil?
      redirect_to root_path, notice: "ログインしてください"
    end
  end
end
