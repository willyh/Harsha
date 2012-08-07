class SettingsController < ApplicationController
  def edit
    Setting.create if(Setting.all.empty?)
    @settings = Setting.first
    @head = 'Edit Settings'
  end

  def update
    @settings = Setting.first
    attrs = params[:setting]
    o = @settings.opens_at
    open = Time.local(o.year,o.month,o.day,
      params[:opens_at_hour].to_i % 12 + (12*((params[:opens_at_ampm] == "AM") ? 0 : 1)),
      params[:opens_at_min].to_i)
    attrs[:opens_at] = open
    c = @settings.closes_at
    close = Time.local(c.year,c.month,c.day,
      params[:closes_at_hour].to_i % 12 + (12*((params[:closes_at_ampm] == "AM") ? 0 : 1)),
      params[:closes_at_min].to_i)
    attrs[:closes_at] = close

    if @settings.update_attributes(attrs)
      flash[:success] = "Save successful"
      redirect_to edit_setting_url(@settings)
    else
      flash[:error] = "Something went wrong"
      redirect_to edit_setting_url(@settings)
    end
  end

  def activate
    @settings = Setting.first
    now = Time.now
    @settings.last_activation_date = now
    @settings.opens_at = Time.local(now.year,now.month,now.day,
                                   @settings.opens_at.localtime.hour,
                                   @settings.opens_at.localtime.min)
    @settings.closes_at = Time.local(now.year,now.month,now.day,
                                   @settings.closes_at.localtime.hour,
                                   @settings.closes_at.localtime.min)
    @settings.save
    if active?
      flash[:success] = "Online ordering has been activated"
    else
      flash[:error] = "Unable To Activate: It's already past closing time"
    end
    redirect_to edit_setting_path(1)
  end

  def turn_off
    @settings = Setting.first
    now = Time.now
    @settings.last_activation_date = Time.local(now.year,now.month,now.day,
                                   @settings.closes_at.localtime.hour,
                                   @settings.closes_at.localtime.min)
    @settings.save
    unless active?
      flash[:success] = "Online ordering has been turned off"
    end
    redirect_to edit_setting_path(1)
  end
  
  protected
  def active?
    return Setting.first.last_activation_date < Time.now && Time.now < Setting.first.closes_at
  end
end
