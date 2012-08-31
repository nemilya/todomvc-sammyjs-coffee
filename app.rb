require "rubygems"
require "sinatra"
require "haml"


get "/" do
  haml :index
end

# some cache issues
get '/:name.template' do
  file_path = "public/templates/#{params[:name]}.template"
  File.open(file_path).read if File.exists?(file_path)
end

