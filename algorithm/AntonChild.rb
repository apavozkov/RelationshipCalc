require 'json'

class AntonChild
  def self.from_txt_to_json(filename)
    if File.exist?(filename)
      # Чтение всего файла в переменную
      text = File.read(filename)

      # Разделение текста на секции
      sections = text.split("#")[1..-1]  # Игнорируем первый пустой элемент
      names_section = sections[0].strip.split("\n")[1..-1]  # Игнорируем заголовок
      marriages_section = sections[1].strip.split("\n")[1..-1]  # Игнорируем заголовок
      parent_child_section = sections[2].strip.split("\n")[1..-1]  # Игнорируем заголовок

      gender_mapping = {
        'Ж' => 'W',
        'М'=> 'M'
      }

      # Парсинг имен
      people = []
      names_section.each do |line|
        if line.strip != ""
          name, gender = line.strip.split(" (")
          gender = gender.chop  # Убираем закрывающую скобку
          gender = gender_mapping[gender] || gender
          people << { "name" => name, "gender" => gender }
        end
      end

      # Парсинг браков
      marriages = []
      marriages_section.each do |line|
        if line.strip != ""
          husband, wife = line.strip.split(" <-> ")
          marriages << { "husband" => husband, "wife" => wife }
        end
      end

      # Парсинг родительских связей
      parent_child = []
      parent_child_section.each do |line|
        if line.strip != ""
          parent, child = line.strip.split(" -> ")
          parent_child << { "parent" => parent, "child" => child }
        end
      end

      # Создание итогового JSON
      data = {
        "people" => people,
        "marriages" => marriages,
        "parent_child" => parent_child
      }

      # Сохранение в файл
      File.open("people.json", "w:UTF-8") do |f|
        f.write(JSON.pretty_generate(data))
      end

      puts "JSON создан и сохранен в файл people.json"
    else
      puts "Ошибка. Файл #{filename} не найден."
    end
  end
end
