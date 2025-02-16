class Api::V1::NamesController < ApplicationController
  def index
    persons = Person.all
    render json: persons, status: 200
  end

  def create
    person = Person.new(
      name: params[:name],
      gender: params[:gender]
    )
    if person.save
      render json: person, status: 200 else
      render json: {error: "Error creating person."} end
  end
end
  