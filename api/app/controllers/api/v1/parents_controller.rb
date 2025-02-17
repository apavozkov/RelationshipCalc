class Api::V1::ParentsController < ApplicationController
  def index
    relations = Parent.all
    render json: relations, status: 200
 end

 def create
    relation = Parent.new(
      parent: params[:parent],
      child: params[:child]
    )
    if relation.save
      render json: relation, status: 200 else
      render json: {error: "Error creating relation."} end
  end
end
