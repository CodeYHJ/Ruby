#!/usr/bin/ruby
require  'socket'

def parse(request)
    method,path,version = request.lines[0].split
    {
        path:path,
        method:method,
        headers: parse_headers(request)
    }
end

def parse_headers(request)
    headers={}

    def normalize(header)
        header.gsub(":","").downcase.to_sym
    end

    request.lines[1..-1].each do |line|
        return headers if line == "\r\n"

        header,value=line.split

        header = normalize(header)

        headers[header]=value
    end


end

SERVER_ROOT = "./"

def parepare_response(request)
    if request.fetch(:path)=="/"
        respond_width(SERVER_ROOT+"index.html")
    else
        respond_width(SERVER_ROOT+request.fetch(:path))
    end
end

def respond_width(path)
    puts File.exists?('./index.html'),11111
    if File.exists?(path)
        send_ok_response(File.binread(path))
    else
        send_file_not_found
    end
end

def send_ok_response(data)
    Response.new(code: 200, data: data)
end
  
def send_file_not_found
    Response.new(code: 404)
end

class Response
    def initialize(code:, data: "")
      @response =
      "HTTP/1.1 #{code}\r\n" +
      "Content-Length: #{data.size}\r\n" +
      "\r\n" +
      "#{data}\r\n"
    end

    def send(client)
      client.write(@response)
    end
end

server = TCPServer.new('localhost',8081)

loop {
    client = server.accept
    request = client.readpartial(2048)
    request = parse(request)
    puts request.fetch(:path)

    puts request

    response= parepare_response(request)

    puts response

    response.send(client)
    client.close
    # puts request
}