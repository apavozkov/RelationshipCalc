require_relative 'Anton'

class AlgorithmJsonInput < Anton

  def self.load_people_data(file_path)
    unless File.exist?(file_path)
      warn "Файл #{file_path} не найден."
      return nil
    end

    begin
      data = JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      warn "Ошибка в формате JSON: #{e.message}"
      return nil
    end

    people = {}

    data['people'].each do |person|
      name = person['name']
      people[name] = {
        gender: person['gender'],
        spouses: [],
        parents: [],
        children: []
      }
    end

    data['marriages']&.each do |marriage|
      husband = marriage['husband']
      wife = marriage['wife']
      people[husband][:spouses] << wife unless people[husband][:spouses].include?(wife)
      people[wife][:spouses] << husband unless people[wife][:spouses].include?(husband)
    end

    data['parent_child']&.each do |pc|
      parent = pc['parent']
      child = pc['child']
      people[parent][:children] << child unless people[parent][:children].include?(child)
      people[child][:parents] << parent unless people[child][:parents].include?(parent)
    end

    people
  end

  # Загрузка формул
  def self.load_formulas(file_path)
    unless File.exist?(file_path)
      warn "Файл #{file_path} не найден."
      return nil
    end

    begin
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      warn "Ошибка в формате JSON: #{e.message}"
      return nil
    end
  end
end