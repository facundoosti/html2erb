require 'rest-client'
require 'fileutils'
require 'json'

module Haml2ErbConverter
  extend self

  URL = 'https://haml2erb.org/api/convert'

  def parse(content = nil)
    payload = {haml: content, converter: :herbalizer}
    response = RestClient.post(URL, payload, {})
    JSON.parse(response.body)["erb"]
  end
end

module FileSysHaml2Erb
  extend self
  def create(origin)
    @origin = origin
    init
    process
    print_errors
  end

  private
  def init
    raise "Directorio no existe: #{@origin}" unless File.directory?(@origin)
    @destination = "./fs"
    Dir.mkdir(@destination) unless Dir.exist?(@destination)
    @paths = Dir["#{@origin}/**/*.haml"]
    @errors = []
  end

  def process
    @paths.each do |path|
      content = File.read(path)
      path = path.gsub(@origin, '').gsub('haml','erb')
      path_name = "#{@destination}#{path}"
      dir_create(path_name)
      begin
        content = Haml2ErbConverter.parse(content)
        File.open(path_name, "w+") { |file| file.write(content) }
        puts "Archivo creado; nombre: #{path_name}"
      rescue
        @errors << path
      end
    end
  end

  def dir_create(path)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end

  def print_errors
    puts "Rutas con errores"
    @errors.each{|error| puts error}
  end
end
