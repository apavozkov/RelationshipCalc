require_relative '../../../../../Algorithm/AlgorithmDbInput'

class Api::V1::SearchController < ApplicationController
  def index
    @relatives = AlgorithmDbInput.run(params[:name])
    render json: @relatives, status: 200
  end
end
