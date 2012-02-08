Factory.sequence :uri do |n|
  "http://example.org/test-url#{n}/"
end

Factory.define :url do |u|
  u.url { Factory.next :uri }
  u.title "Something"
  u.status "checked"
end

Factory.define :occurrence do |o|
  o.association :url, :factory => :url
  o.association :channel, :factory => :channel
  o.association :nick, :factory => :nick
end

Factory.define :private_occurrence => :occurrence do |o|
  o.public false
end
