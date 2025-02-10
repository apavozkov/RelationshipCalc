require 'sinatra'
require 'json'
require_relative 'Anton'
require_relative 'AntonChild'

def load_formulas
    if File.exist?('formulas.json')
        JSON.parse(File.read('formulas.json'))
    else
        @error = "Отсутствует файл formulas.json"
    end
end

def save_formulas(formulas)
    File.write('formulas.json', JSON.pretty_generate(formulas))
end

get '/' do
    erb :index
end

post '/search' do
    name = params[:name]

    @relatives = Anton.run(name)

    if File.exist?('output.json')
        @relatives = JSON.parse(File.read('output.json'))
    else
        @error = "У Антона сегодня выходной."
    end

    if @error
        erb :error
    else
        erb :results
    end
end

post '/update' do

    filename = "input.txt"
    
    begin
        AntonChild.from_txt_to_json(filename)
        @message = "База данных успешно обновлена."

    rescue => e
        @error = "Ошибка при обновлении базы данных: #{e.message}"
    end

    if @error
        erb :error
    else
        redirect '/'
    end
end

get '/formulas' do
    @formulas = load_formulas
    erb :formulas
end

get '/formulas/add' do
    erb :add_formula
end

post '/formulas/add' do
    type = params[:type]
    formula = params[:formula]
  
    formulas = load_formulas
    formulas[type] = formula
    save_formulas(formulas)
  
    redirect '/formulas'
end

get '/formulas/edit/:type' do
    @type = params[:type]
    formulas = load_formulas
    @formula = formulas[@type]
    erb :edit_formula
end

post '/formulas/edit/:type' do
  old_type = params[:type]
  new_type = params[:new_type]
  formula = params[:formula]

  formulas = load_formulas
  formulas.delete(old_type)
  formulas[new_type] = formula
  save_formulas(formulas)

  redirect '/formulas'
end

post '/formulas/delete/:type' do
    type = params[:type]
  
    formulas = load_formulas
    formulas.delete(type)
    save_formulas(formulas)
  
    redirect '/formulas'
  end

get '/formulas/view/:type' do
    @type = params[:type]
    formulas = load_formulas
    @formula = formulas[@type]
    erb :view_formula
end

if __FILE__ == $0
    set :bind, '0.0.0.0'
    set :port, 4567
end