#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true

  return @db
end

configure do
  init_db

  @db.execute 'CREATE TABLE IF NOT EXISTS "Posts" (
  "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "created_date"	DATE,
  "content"	TEXT,
  "name" TEXT
  );'

  @db.execute 'CREATE TABLE IF NOT EXISTS "Comments" (
  "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "created_date"	DATE,
  "content"	TEXT,
  "post_id" INTEGER
  );'
end

before do
  init_db
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc;'

	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @content = params[:content]
  @name = params[:name]

  if @content.size <= 0
    @error = 'Вы не ввели никакого сообщения'
    return erb :new
  end

  @db.execute 'insert into Posts (content, created_date, name) values (?, datetime(), ?);', [@content, @name]

  redirect to('/')
end


get '/posts' do
  erb :posts
end

get '/details/:post_id' do # Understand, yeah man!)
  post_id = params[:post_id]

  @results = @db.execute 'select * from posts where id = ?;', [post_id]
  @row = @results[0]

  @comments = @db.execute "select * from Comments where post_id = ? order by id;", [post_id]

  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  content = params[:content]

  @db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?);', [content, post_id]

  redirect to('/details/' + post_id)
end