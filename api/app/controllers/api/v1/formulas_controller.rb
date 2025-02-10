class Api::V1::FormulasController < ApplicationController
  def index
    formulas = Formula.all
    render json: formulas, status: 200
  end

  def create
    formula = Formula.new(
      name: params[:name],
      formula: params[:formula]
    )
    if formula.save
      render json: formula, status: 200 else
      render json: {error: "Error creating formula."} end
  end
end
