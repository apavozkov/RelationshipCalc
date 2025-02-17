require 'json'
require 'thread'

class Anton

  def self.fill_person_data(persons, marriages, parent_child)
    people = {}

    persons.each do |person|
        name = person['name']
        people[name] = {
          gender: person['gender'],
          spouses: [],
          parents: [],
          children: []
        }
    end
    
    marriages.each do |marriage|
        husband = marriage['husband']
        wife = marriage['wife']
        people[husband][:spouses] << wife unless people[husband][:spouses].include?(wife)
        people[wife][:spouses] << husband unless people[wife][:spouses].include?(husband)
    end

    parent_child.each do |pc|
        parent = pc['parent']
        child = pc['child']
        people[parent][:children] << child unless people[parent][:children].include?(child)
        people[child][:parents] << parent unless people[child][:parents].include?(parent)
    end

    return people
  end

  # Разбор шага формулы на операцию и пол
  def self.parse_step(step_str)
    match = step_str.match(/^(ELDRE|LIK|UNG)\(([MW])\)$/)
    { op: match[1], gender: match[2] } if match
  end

  # Применение одного шага формулы к текущему набору людей
  def self.apply_step(person_name, step, people_data, excluded_names)
    person = people_data[person_name]
    return [] unless person

    case step[:op]
    when 'ELDRE'
      person[:parents].filter { |p| people_data.dig(p, :gender) == step[:gender] }
    when 'LIK'
      person[:spouses].filter { |s| people_data.dig(s, :gender) == step[:gender] }
    when 'UNG'
      person[:children].filter { |c| people_data.dig(c, :gender) == step[:gender] }
    else
      []
    end.reject { |name| excluded_names.include?(name) } # Исключаем промежуточные имена
  end

  # Обработка подформулы для получения списка родственников
  def self.process_sub_formula(sub_formula, start_person, people_data)
    steps = sub_formula.split('/').map { |s| parse_step(s) }.compact
    return [] if steps.empty?

    current = [start_person]
    excluded_names = [start_person] # Исключаем исходного человека

    steps.each do |step|
      current = current.flat_map { |person| apply_step(person, step, people_data, excluded_names) }.uniq
      excluded_names += current # Добавляем текущие имена в исключения
      return [] if current.empty? # Если на каком-то шаге нет людей, возвращаем пустой результат
    end
    current
  end

  # Вычисление родственников по формуле
  def self.calculate_relatives(formula, start_person, people_data)
    return [] unless people_data.key?(start_person)

    sub_formulas = formula.split('&&')
    results = []
    sub_formulas.each do |sub|
      next unless valid_formula?(sub) # Пропустить невалидные части формулы
      relatives = process_sub_formula(sub, start_person, people_data)
      results += relatives unless relatives.empty? # Добавляем только непустые результаты
    end
    results.uniq
  end

  # Проверка валидности формулы
  def self.valid_formula?(formula)
    return false if formula.empty?
    formula.split('/').all? do |step|
      step.match?(/^(ELDRE|LIK|UNG)\([MW]\)$/)
    end
  end

  # Основная функция программы
  def self.run(start_person, people_file = 'people.json', formulas_file = 'formulas.json')
    # Загрузка данных
    people_data = load_people_data(people_file) || exit(1)
    formulas = load_formulas(formulas_file) || exit(1)
  
    begin
      result = {}
      mutex = Mutex.new

      threads = formulas.map do |type, formula|
        Thread.new do
          relatives = calculate_relatives(formula, start_person, people_data)
          mutex.synchronize do
            result[type] ||= []
            result[type] += relatives
            result[type].uniq!
          end
        end
      end

      threads.each(&:join)

      # Обработка и сохранение результатов
      result.each { |k, v| result[k] = v.empty? ? 'none' : v.sort }
      File.write('output.json', JSON.pretty_generate(result))

    rescue => e
      warn "Критическая ошибка: #{e.message}"
      exit 1
    end

    result
  end


  # Метод для получения информации о человеке
  def self.get_person_info(person_name, file_path = 'data.json')
    people = load_people_data(file_path)
    if people.nil?
      warn "Не удалось загрузить данные."
      return nil
    end

    if people[person_name].nil?
      warn "Человек с именем #{person_name} не найден."
      return nil
    end

    people[person_name]
  end
end

if __FILE__ == $0 && !ENV['TEST_MODE']
  if ARGV.empty?
    warn "Укажите имя человека в качестве аргумента."
    exit 1
  end

  person_name = ARGV[0]
  file_path = 'data.json' # Укажите путь к вашему файлу данных

  person_info = Anton.get_person_info(person_name, file_path)
  if person_info
    puts "Информация о человеке #{person_name}:"
    puts person_info
  else
    exit 1
  end
end