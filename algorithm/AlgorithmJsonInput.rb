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
    return self.fill_person_data(data['people'], data['marriages'],data['parent_child'])
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