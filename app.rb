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

  @db.execute 'CREATE TABLE IF NOT EXISTS `Comments` (
    `id`  INTEGER PRIMARY KEY AUTOINCREMENT,
    `Create_Date` TEXT,
    `Content` TEXT,
    `post_id` INTEGER
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
  # получаем переменную из url'a
  post_id = params[:post_id]

  # Получаем список постов (здесь должен быть только один пост)
  results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  # Берём этот один пост и сохроняем в переменной @row
  @row = results[0]

  # Выбираем комментарии для нашего поста
  comments = db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]

  # Возвращаем представление :details
  erb :details
end

# Обработчи пост запроса details (браузер отправляет данные на сервер и мы их принимаем)
post '/details/:post_id' do
  # получаем переменную из url'a
  post_id = params[:post_id]
  # получаем текст комментария
  content = params[:area]

  #сохранение данных в бд
  @db.execute 'insert into Comments (create_date, content, post_id) values(datetime(), ?, ?);', [content, post_id]

  # Перенаправляем на страницу поста
  redirect to ('/details/' + post_id)
end