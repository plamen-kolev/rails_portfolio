class PagesController < ApplicationController
  def index
    @articles = Article.all
    # a = render 'pages/index'
    # expires_in 3.days, :public => true
    # fresh_when @articles
  end

  def keybase
    @keybase_fp = 'hKRib2R5hqhkZXRhY2hlZMOpaGFzaF90eXBlCqNrZXnEIwEgW516ZGqInOKwnCCB/dPKp1aAR16qXYAujMhztq47F7MKp3BheWxvYWTFAvN7ImJvZHkiOnsia2V5Ijp7ImVsZGVzdF9raWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwiaG9zdCI6ImtleWJhc2UuaW8iLCJraWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwidWlkIjoiYjI3ZDliY2VjNmQyOTQ2NTcxYTI4MDUyZTVlMWJkMTkiLCJ1c2VybmFtZSI6InBsYW1lbmtvbGV2In0sInNlcnZpY2UiOnsiaG9zdG5hbWUiOiJrb2xldi5pbyIsInByb3RvY29sIjoiaHR0cDoifSwidHlwZSI6IndlYl9zZXJ2aWNlX2JpbmRpbmciLCJ2ZXJzaW9uIjoxfSwiY2xpZW50Ijp7Im5hbWUiOiJrZXliYXNlLmlvIGdvIGNsaWVudCIsInZlcnNpb24iOiIxLjAuMTgifSwiY3RpbWUiOjE0ODc3MDA2MTEsImV4cGlyZV9pbiI6NTA0NTc2MDAwLCJtZXJrbGVfcm9vdCI6eyJjdGltZSI6MTQ4NzcwMDYwMiwiaGFzaCI6ImMwYzJiNzhhMTBlOWM2ZTkzYTcyYWIzYWQ1M2ZmZWU2MzNkOTU3ODdmYzU3YjY5NDdjMzYzNTQxYzc4ZjcyNWQ2YWYxZTE1MDc4ZjdjN2FkMWY3ZWQwYTViOTJiZDY4MzA3YTdiYWZjOTM0NzNiZDVlZDZkMjdmZWNlYWI5MTU1Iiwic2Vxbm8iOjkxMTI0OX0sInByZXYiOiJkNzVhNDczZDUxOTBjZmM0ZDQyMmJhY2M5ODg5ZjFmNzk2ZDkxNThjN2JjODQwZGE1ZDk3OGY4YmQyNjg3MzgwIiwic2Vxbm8iOjE3LCJ0YWciOiJzaWduYXR1cmUifaNzaWfEQCXV2wYy8DQAToIZpBq7BRIHvx757tI30SqPwXLJKJ+PWp91+I8WY9KxQLIpN9t9LcaNFGm8FJqh75aG3ITUIAGoc2lnX3R5cGUgpGhhc2iCpHR5cGUIpXZhbHVlxCA8LYZBNOM5DjSHiQSvZ0VddSOO+58J7kZSyFwMLwAUeqN0YWfNAgKndmVyc2lvbgE='
    render plain: @keybase_fp
  end

  def cname
    @cname = 'kolev.io'
    render plain: @cname
  end

  def robots
    @rfile = <<-HERE
User-agent: *
Disallow:
HERE
    render plain: @rfile
  end

  def error_404
    render(:status => 404)
  end
end
