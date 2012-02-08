class UrlImage < ActiveRecord::Base
  has_many                :urls, :dependent => :destroy
  has_attached_file       :image,
                          :styles => {
                            :thumb=> "80x80#",
                            :preview => "140x140#"
                          },
                          :url => "/images/urlimg/:style/:hashed_path/:id.:extension",
                          :path => ":rails_root/public/images/urlimg/:style/:hashed_path/:id.:clean_extension"
  
  validates_attachment_presence :image
end
