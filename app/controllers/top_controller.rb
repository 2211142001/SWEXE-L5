class TopController < ApplicationController
  def main
    @tweets = Tweet.all
  end

  def signup
    @user = User.new
  end

  def signup_post
    if session[:user_id]
      redirect_to root_path, notice: "ログイン済みです"
    end

    if User.exists?(uid: user_params[:uid])
      @user = User.new
      flash[:message] = "このIDは既に使用されています"
      render :signup, status: :unprocessable_entity
    else
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
  end

  def signin
    @user = User.new
  end

  def signin_post
    if session[:user_id]
      redirect_to root_path, notice: "ログイン済みです"
    end

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

  private

  def user_params
    params.require(:user).permit(:uid, :pass)
  end
end
