class Api::V1::RelationsController < ApplicationController
 def index
    relations = Relation.all
    render json: relations, status: 200
 end
end
