class SettingsController < ApplicationController
  def edit
    @settings = Setting.first
    @head = 'Edit Settings'
  end
  def update
    @settings = Setting.find(params[:id])

    if @settings.update_attributes(params[:setting])
        flash[:success] = "Save successful"
        redirect_to edit_setting_url(@settings)
    else
        redirect_to edit_setting_url(@settings)
    end
  end
end
