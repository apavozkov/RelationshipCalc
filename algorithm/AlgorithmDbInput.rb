require_relative 'Anton'

class AlgorithmDbInput < Anton
  # Загрузка данных о людях, браках и родительских связях
  def self.load_people_data(file_path)
    people = {}

    Person.all.each do |person|
      name = person['name']
      people[name] = {
        gender: person['gender'],
        spouses: [],
        parents: [],
        children: []
      }
    end

    Marriage.all.each do |marriage|
      husband = marriage['husband']
      wife = marriage['wife']
      people[husband][:spouses] << wife unless people[husband][:spouses].include?(wife)
      people[wife][:spouses] << husband unless people[wife][:spouses].include?(husband)
    end

    Parent.all.each do |pc|
      parent = pc['parent']
      child = pc['child']
      people[parent][:children] << child unless people[parent][:children].include?(child)
      people[child][:parents] << parent unless people[child][:parents].include?(parent)
    end

    people
  end

  # Загрузка формул
  def self.load_formulas(file_path)
    return {
    "Супруг": "LIK(M)",
    "Супруга": "LIK(W)",
    "Сын": "UNG(M)",
    "Дочь": "UNG(W)",
    "Мать": "ELDRE(W)&&ELDRE(M)/LIK(W)",
    "Отец": "ELDRE(M)",
    "Брат": "ELDRE(M)/UNG(M)",
    "Сестра": "ELDRE(M)/UNG(W)",
    "Внук": "UNG(M)/UNG(M)&&UNG(W)/UNG(M)",
    "Внучка": "UNG(M)/UNG(W)&&UNG(W)/UNG(W)",
    "Дедушка": "ELDRE(M)/ELDRE(M)&&ELDRE(W)/ELDRE(M)",
    "Бабушка": "ELDRE(W)/ELDRE(W)&&ELDRE(M)/ELDRE(W)",
    "Свояченица": "LIK(W)/ELDRE(M)/UNG(W)",
    "Свояк": "LIK(W)/ELDRE(M)/UNG(W)/LIK(M)",
    "Шурин": "LIK(W)/ELDRE(M)/UNG(M)",
    "Невестка": "LIK(W)/ELDRE(M)/UNG(M)/LIK(W)&&LIK(M)/ELDRE(M)/UNG(M)/LIK(W)",
    "Тесть": "LIK(W)/ELDRE(M)",
    "Теща": "LIK(W)/ELDRE(W)",
    "Сверковь": "LIK(M)/ELDRE(W)",
    "Свекр": "LIK(M)/ELDRE(M)",
    "Сноха": "UNG(M)/LIK(W)"
  }
  end
end