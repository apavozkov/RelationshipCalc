require 'json'
require 'thread'

class Api::V1::SearchController < ApplicationController

  # Разбор шага формулы на операцию и пол
  def parse_step(step_str)
    match = step_str.match(/^(ELDRE|LIK|UNG)\(([MW])\)$/)
    { op: match[1], gender: match[2] } if match
  end

  # Применение одного шага формулы к текущему набору людей
  def apply_step(person_name, step, people_data, excluded_names)
    person = people_data.find_by("dependant = ? OR relative = ?", person_name, person_name)
    person =  {
      gender: person['gender'],
      spouses: [],
      parents: [],
      children: []
    }
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

  def valid_formula?(formula)
    formula.split('/').all? do |step|
      step.match?(/^(ELDRE|LIK|UNG)\([MW]\)$/)
    end
  end

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
    sub_formulas = formula.split('&&')
    results = []
    sub_formulas.each do |sub|
      next unless valid_formula?(sub) # Пропустить невалидные части формулы
      relatives = process_sub_formula(sub, start_person, people_data)
      results += relatives unless relatives.empty? # Добавляем только непустые результаты
    end
    results.uniq
  end

  def index
    people_data = Relation.all
    formulas =  Formula.all
   
    begin
     result = {}
      mutex = Mutex.new

      threads = formulas.map do |f|
        Thread.new do
          relatives = calculate_relatives(f.formulas, params[:name], people_data)
          mutex.synchronize do
            result[f.name] ||= []
            result[f.name] += relatives
            result[f.name].uniq!
          end
        end
      end

      threads.each(&:join)

      # Обработка и сохранение результатов
      result.each { |k, v| result[k] = v.empty? ? 'none' : v.sort }
    render json: result, status: 200
  end
end
end
