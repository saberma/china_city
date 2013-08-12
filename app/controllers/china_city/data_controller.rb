require_dependency "china_city/application_controller"

module ChinaCity
  class DataController < ApplicationController
    layout nil
    def show
      data = ChinaCity.list(params[:id])
      render json: data
    end
  end
end
