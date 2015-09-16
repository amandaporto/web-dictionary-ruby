require "webrick"
require 'json'

class AddWordFromJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    word       = request.query["word"]
    definition = request.query["definition"]

    File.open("dictionary.txt", "a+") do |file|
      file.puts "#{word} = #{definition}"
    end

    response.status = 201
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body = {status: :ok}.to_json
  end
end

class ServeWordsInJSON < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request,response)
    dictionary_lines = File.readlines("dictionary.txt")

    array_of_hashes = dictionary_lines.map do |line|
      word, definition = line.chomp.split(" = ")
      {
        word: word,
        definition: definition
      }
    end

    response.status = 200
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body   = array_of_hashes.to_json
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    dictionary_lines = File.readlines("dictionary.txt")
    search_results = dictionary_lines.select {|line| line.include?(request.query["q"])}

    search_array = search_results.map do |line|
      definition, word = line.chomp.split(" = ")
      {
        definition: definition,
        word: word
      }
    end

    response.status = 200
    response["Access-Control-Allow-Origin"] = "*"
    response["Content-Type"] = "application/json"
    response.body = search_array.to_json
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount "/words.json", ServeWordsInJSON
server.mount "/create", AddWordFromJSON
server.mount "/search", SearchWord

trap "INT" do server.shutdown end
server.start

# Link to Web Dictionary. Must have server started.
# http://tiy-tpa-ruby-q3-2015.github.io/web-dict-static/
