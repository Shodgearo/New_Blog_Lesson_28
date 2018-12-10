#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'astroblog'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS `Posts` (
	  `id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	  `Create_Date`	TEXT,
	  `Content`	TEXT
  )'
end

get '/' do
  #Выбираем список постов из базы
  @results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'

	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  area = params[:area]

  if area.length <= 0
    @error = 'Введите текст поста.'
    return erb :new
  end

  #сохранение данных в бд
  @db.execute 'insert into Posts (create_date, content) values(datetime(), ?);', [area]

  #Перенаправление на главную страницу
  redirect to '/'
end

#Вывод информации о посте.
get '/details/:post_id' do
  post_id = params[:post_id]

  results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  @row = results[0]

  erb :details
end