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
    user = current_user
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
    if tweet.user_id != current_user.id
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
    tweet = Tweet.find(params[:id])
    if tweet.liked?(current_user)
      flash[:message] = "このツイートは既にいいねされています"
      redirect_to root_path, status: :unprocessable_entity
      return
    end

    if tweet.like(current_user)
      flash[:message] = "ツイートをいいねしました"
      redirect_to root_path
    else
      flash[:message] = "ツイートのいいねに失敗しました"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def unlike_tweet
    tweet = Tweet.find(params[:id])
    if tweet.liked?(current_user)
      if tweet.unlike(current_user)
        flash[:message] = "ツイートのいいねを解除しました"
        redirect_to root_path
      else
        flash[:message] = "ツイートのいいね解除に失敗しました"
        redirect_to root_path, status: :unprocessable_entity
      end
    else
      flash[:message] = "このツイートはいいねされていません"
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def profile
    @profile = current_user || Profile.new(user_id: current_user.id)
  end

  def update_profile
    @profile = current_user || Profile.new(user_id: current_user.id)
    @profile.message = params[:profile][:message]

    if @profile.save
      @profile = current_user
      flash[:message] = "プロフィールを更新しました"
      redirect_to profile_path
    else
      flash[:message] = "プロフィールの更新に失敗しました"
      render :profile, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:uid, :pass)
  end

  def redirect_if_signed_in
    if current_user
      redirect_to root_path, notice: "ログイン済みです"
    end
  end

  def redirect_if_signed_out
    if current_user.nil?
      redirect_to root_path, notice: "ログインしてください"
    end
  end
end
