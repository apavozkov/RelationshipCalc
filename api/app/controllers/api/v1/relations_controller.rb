class Api::V1::RelationsController < ApplicationController
 def index
    relations = Relation.all
    render json: relations, status: 200
 end

 def create
    relation = Relation.new(
      relative: params[:relative],
      dependant: params[:dependant],
      relation: params[:relation]
    )
    if relation.save
      render json: relation, status: 200 else
      render json: {error: "Error creating relation."} end
  end

end
