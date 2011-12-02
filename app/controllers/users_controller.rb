class UsersController < ApplicationController
  load_and_authorize_resource
  def new
  end

  def create
    if @user.save
      sign_in @user
      redirect_to @user
    else
      render :action => :new
    end
  end

  def activate
    if params[:user][:code_check] == @user.code
      @user.update_attribute :activated, true
      @user.do_activate
      redirect_to @user
    else
      @error = true
      render :action => :show
    end
  end

  def resend_code
    if @user.sms.count > 9
      @too_many_sms = true
    else
      @user.resend_code
    end
    redirect_to @user
  end

  def index
  end

  def show
  end
end
