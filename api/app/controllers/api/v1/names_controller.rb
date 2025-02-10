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
# # This method looks up the product by the id, if it is found we render the ison object
# # Otherwise we render an error object.
#   def show
#     person = Person.find_by(name: params[:name])
#     if person
#       render json: person, status: 200 else
#       render json: ferror: "Product Not Found."} end end
# # # This private method is only available to this controller.
# # # It uses the the built-in methods . require and permit provided by ActionController
# private
# def prod_params
# params. require (:product) .permit(I
# : name, brand, price, :description
# end
end
  