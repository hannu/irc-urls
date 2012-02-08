Factory.define :network do |f|
  f.sequence(:name) {|n| "test-network-#{n}" }
end

Factory.define :channel do |f|
  f.association :network, :factory => :network
  f.sequence(:name) { |n| "#test-channel-#{n}"}
end

Factory.sequence :nick_name do |n|
  "irc-user-#{n}"
end

Factory.define :nick do |n|
  n.name Factory.sequence :nick_name
  n.ident "foo"
  n.host "example.org"
  n.association :network, :factory => :network
end
