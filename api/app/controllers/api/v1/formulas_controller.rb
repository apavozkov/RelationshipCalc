class Api::V1::FormulasController < ApplicationController
  def index
    formulas = Formula.all
    render json: formulas, status: 200
  end

  # def create
  #   formula = Formula.new(
  #     name: params[:name],
  #     formula: params[:formula]
  #   )
  #   if formula.save
  #     render json: formula, status: 200 else
  #     render json: {error: "Error creating formula."} end
  # end

  def create
    base_formula = Formula.where(["name = '%s'", params[:sub_formula]]).pluck(:formula).first 
    base_formula +=  params[:operation]
    base_formula +=  params[:additive_formula]
    formula = Formula.new(
      name: params[:name],
      formula: base_formula
    )
    if formula.save
      render json: formula, status: 200 else
      render json: {error: "Error creating formula."} end
  end

end
