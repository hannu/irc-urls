Factory.sequence :email do |n|
  "test-user-#{n}@example.com"
end

Factory.sequence :login do |n|
  "test-user-#{n}"
end

Factory.define :user do |u|
  u.login { Factory.next :login }
  u.name 'John Doe'
  u.email { |u| "#{u.login}@example.com" }
  u.password 'test-user-password'
  u.password_confirmation 'test-user-password'
  u.after_create  { |u| u.confirm! }
end

Factory.define :unconfirmed_user => :user do |u|
end
