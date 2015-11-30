# encoding: utf-8
require_dependency "china_city/application_controller"
require 'spinying'

module ChinaCity
  class DataController < ApplicationController
    def show
      data = ChinaCity.list(params[:id])
      render json: data, layout: nil
    end

    def index
      #puts Spinying.parse(:world => 'hello')
      #text = Spinying.parse(:world => district['text']).upcase + ' ' + district['text']
    end
  end
end
