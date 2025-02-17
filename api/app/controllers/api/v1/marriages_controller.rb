class Api::V1::MarriagesController < ApplicationController
  def index
    relations = Marriage.all
    render json: relations, status: 200
 end

 def create
    relation = Marriage.new(
      husband: params[:husband],
      wife: params[:wife]
    )
    if relation.save
      render json: relation, status: 200 else
      render json: {error: "Error creating relation."} end
  end
end
