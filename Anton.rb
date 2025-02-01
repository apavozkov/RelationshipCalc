require 'json'
require 'thread'

# Загрузка данных о людях, браках и родительских связях
def load_people_data(file_path)
  unless File.exist?(file_path)
    puts "Файл #{file_path} не найден."
    exit
  end

  begin
    data = JSON.parse(File.read(file_path))
  rescue JSON::ParserError => e
    puts "Ошибка в формате JSON: #{e.message}"
    exit
  end

  people = {}

  # Инициализация записей о людях
  data['people'].each do |person|
    name = person['name']
    people[name] = {
      gender: person['gender'],
      spouses: [],
      parents: [],
      children: []
    }
  end

  # Обработка браков
  data['marriages']&.each do |marriage|
    husband = marriage['husband']
    wife = marriage['wife']
    people[husband][:spouses] << wife unless people[husband][:spouses].include?(wife)
    people[wife][:spouses] << husband unless people[wife][:spouses].include?(husband)
  end

  # Обработка родительских связей
  data['parent_child']&.each do |pc|
    parent = pc['parent']
    child = pc['child']
    people[parent][:children] << child unless people[parent][:children].include?(child)
    people[child][:parents] << parent unless people[child][:parents].include?(parent)
  end

  people
end

# Загрузка формул родственных связей
def load_formulas(file_path)
  unless File.exist?(file_path)
    puts "Файл #{file_path} не найден."
    exit
  end

  begin
    JSON.parse(File.read(file_path))
  rescue JSON::ParserError => e
    puts "Ошибка в формате JSON: #{e.message}"
    exit
  end
end

# Разбор шага формулы на операцию и пол
def parse_step(step_str)
  match = step_str.match(/^(ELDRE|LIK|UNG)\(([MW])\)$/)
  { op: match[1], gender: match[2] } if match
end

# Применение одного шага формулы к текущему набору людей
def apply_step(person_name, step, people_data, excluded_names)
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
def process_sub_formula(sub_formula, start_person, people_data)
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
def calculate_relatives(formula, start_person, people_data)
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
def valid_formula?(formula)
  formula.split('/').all? do |step|
    step.match?(/^(ELDRE|LIK|UNG)\([MW]\)$/)
  end
end

# Основная функция программы
def main
  start_person = ARGV[0]
  unless start_person
    puts "Укажите имя человека в качестве аргумента."
    exit
  end

  people_data = load_people_data('people.json')
  formulas = load_formulas('formulas.json')

  result = {}
  mutex = Mutex.new

  # Обработка каждой формулы в отдельном потоке
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

  # Обработка пустых результатов
  result.each do |k, v|
    result[k] = v.empty? ? 'none' : v.sort
  end

  # Сохранение результатов в JSON-файл
  File.write('output.json', JSON.pretty_generate(result))
end

main
