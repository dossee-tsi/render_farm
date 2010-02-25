# Task list
get '/' do
  @posts = [] # Temporary
  erb :index
end

# API
get %r{^/api/([\w]+)(?:/([\w]+))?/?$} do |collection, element|
  content_type :json
  {}.to_json
end
