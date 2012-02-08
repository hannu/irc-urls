module Slugify

  def slugify_if_necessary(id, str)
    return "#{id}-#{str.gsub(/[^A-Za-z0-9_!]/, '-')}" if str.match(/(^\d+-.+)|([^A-Za-z0-9_!])/)
    return str
  end
  
end