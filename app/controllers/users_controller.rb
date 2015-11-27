class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render 'new'
    end
  end

  def user_params
    params.require(:user).permit(:name, :gender, :age, :status, :pref_temperature, :credit_temperature, :pref_humidity, :credit_humidity, :pref_light0, :credit_light0,:pref_light1, :credit_light1, :pref_light2, :credit_light2, :pref_light3, :credit_light4)
  end
end
