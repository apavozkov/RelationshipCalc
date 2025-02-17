require_relative 'Anton'

class AlgorithmDbInput < Anton

  def self.load_people_data(file_path)
    return self.fill_person_data(Person.all, Marriage.all,Parent.all)
  end

  def self.load_formulas(file_path)
    formulas = {}
    Formula.all.each do |f|
      formulas[f['name']] = f['formula']
    end
    return formulas
  end
end