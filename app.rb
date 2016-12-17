#!/usr/bin/env ruby
require 'giphy'
require 'open-uri'
require 'digest/sha1'
require 'noun-project-api'

class App
  def run
    setup

    name = ARGV[0] || 'nyan cat'
    url = get_icon(name)
    ext = 'png'

    digested_name = Digest::SHA1.hexdigest(name)
    save_file(url, "#{digested_name}-original.#{ext}")
    resize("#{digested_name}-original.gif", "#{digested_name}-small.#{ext}")
    #edge_detect("#{digested_name}-small.gif", "#{digested_name}-edge.#{ext}")
    colorize("#{digested_name}-small.gif", "#{digested_name}-blue.#{ext}")
    output_to_matrix("#{digested_name}-blue.#{ext}")

  end

  def setup
    Giphy::Configuration.configure do |config|
      config.version = 'v1'
      config.api_key = 'dc6zaTOxFJmzC'
    end

    @noun_token = '3080cd70ddec4718b9e6c7922c6892e1'
    @noun_secret = 'f662db62cad64ddb81472b6792ccf887'

    @debug = true
  end

  def get_gif(name)
    puts "get_gif(#{name})" if @debug
    Giphy.search(name, {limit: 1, rating: 'pg'})[0].original_image.url
  end

  def get_icon(name)
    puts "get_icon(#{name})" if @debug
    icons_finder = NounProjectApi::IconsRetriever.new(@noun_token, @noun_secret)
    result = icons_finder.find(name)[0]
    result.preview_url
  end

  def save_file(url, filename_new)
    open(filename_new, 'wb') do |file|
      file << open(url).read
    end
  end

  def resize(filename_original, filename_new)
    puts "resize(#{filename_original})" if @debug
    system("convert #{filename_original} -resize 32x32 #{filename_new}")
  end

  def edge_detect(filename_original, filename_new)
    puts "edge_detect(#{filename_original})" if @debug
    system("convert #{filename_original} -canny 0x1+10%+30%  #{filename_new}")
  end

  def colorize(filename_original, filename_new)
    puts "colorize(#{filename_original})" if @debug
    system("convert #{filename_original} -colorspace gray +level-colors ,blue  #{filename_new}")
  end

  def output_to_matrix(filename)
    puts "output(#{filename})" if @debug
    # this needs to be generalized or the led-image-viewer should be bundled
    system("sudo /home/pi/rpi-rgb-led-matrix/utils/led-image-viewer --led-no-hardware-pulse --led-gpio-mapping=adafruit-hat -f -t 120 --led-slowdown-gpio=2 #{filename}")
  end
end

App.new.run
