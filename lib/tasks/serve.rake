require 'webrick'

namespace :serve do
  desc "TODO"
  task static: :environment do
    static_path = "#{Dir.pwd}/plamen-kolev.github.io/"
    puts "Open http://localhost:8000"
    WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => static_path).start
  end
end
