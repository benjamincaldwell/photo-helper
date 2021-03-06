# frozen_string_literal: true
class ImageHelper
  IMAGE_CLASS_REGEX = /xmp:Label="(.+)"/
  RATING_REGEX = /xmp:Rating="(.+)"/

# identify -format '%[EXIF:*]' .jepg

  def self.xmp(image)
    xmp = File.join(File.dirname(image), File.basename(image, ".*") + ".XMP")
    return unless File.exist?(xmp)
    File.read(xmp)
  end

  def self.color_class(image)
    contents = xmp(image)
    return if contents.nil?
    matches = contents.match(IMAGE_CLASS_REGEX)
    matches[1] if matches
  end

  def self.contains_color_class?(image, values)
    values = [values] unless values.is_a? Array
    values.include? color_class(image)
  end

  def self.rating(image)
    contents = xmp(image)
    return 0 unless contents
    matches = contents.match(RATING_REGEX)
    return matches[1].to_i if matches && matches[1].match(/^\d+$/)
    0
  end

  def self.is_select?(image)
    contains_color_class?(image, SELECT_COLOR_TAGS) || rating(image) >= SELECT_RATING
  end

  def self.is_5_star?(image)
    rating(image) == '5'
  end

  def self.is_jpeg?(path)
    # remove . from the beginning
    extension = File.extname(path)[1..-1]
    return false if extension.nil?
    JPEG_EXTENSIONS.include? extension.downcase
  end
end
