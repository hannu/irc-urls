Paperclip.interpolates :hashed_path do |attachment, style|
  # Create hash path from image id and style
  # User must not be able to quess images paths or original image path from thumbnail
  
  hash = Digest::MD5.hexdigest("#{style.to_s}Pqksda8tn5hL4a5l15#{attachment.instance.id.to_s}aosIDKlK498dsaKnPwmO")
  hash_path = ''
  3.times { hash_path += '/' + hash.slice!(0..1) }
  hash_path[1..9]
end

# Handling for ?
# Fix bug w/ rails 2.3 (open-uri as filename)
Paperclip.interpolates :clean_extension do |attachment, style|
  ((style = attachment.styles[style]) && style[:format]) || 
    File.extname(attachment.instance.image_file_name).gsub(/^\.+/, "").split(/\?/).first
end