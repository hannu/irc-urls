namespace :ircurls do
  desc "Add test url to database from random tracing, nick and channel"
  task :url => :environment do
    puts "EEEK! Don't do that! You are not in development env." and return unless Rails.env == 'development'
    trackings = Tracking.only_public
    tracking = trackings[rand(trackings.size)]

    nick = Nick.all[rand(Nick.count)]
    channel = tracking.channel

    session = ActionController::Integration::Session.new(IrcUrls::Application)
    session.post("/submissions", {
      :url => ENV["URL"],
      :client_key => tracking.user.client_key,
      :mask => "#{nick.ident}@#{nick.host}",
      :nick => nick.name,
      :channel => channel.name,
      :network => channel.network.name
    })
    puts "[#{session.response.status}] #{session.response.body}"
  end
  
  desc "Generate test data"
  task :generate_data => :environment do
    puts "EEEK! Don't do that! You are not in development env." and return unless Rails.env == 'development'
    
    $stdout.sync = true

    CHANNEL_COUNT = ENV["CHANNEL_COUNT"] || 25
    USER_COUNT = ENV["USER_COUNT"] || 25
    NICK_COUNT = ENV["NICK_COUNT"] || 10 * CHANNEL_COUNT
    URL_COUNT = ENV["URL_COUNT"] || 2 * NICK_COUNT 
    OCCURRENCE_COUNT = ENV["OCCURRENCE_COUNT"] || 2 * URL_COUNT
    MAX_TRACKINGS_COUNT = 4

    @networks = Network.all

    # -- Creating users
    @users = (0...USER_COUNT).to_a.map do |n|
      print "\rCreating users (#{n+1}/#{USER_COUNT})"
      user = User.create! do |u|
        u.login = "user#{n}"
        u.email = "user#{n}@irc-urls.net"
        u.password = "userpass#{n}"
        u.password_confirmation = "userpass#{n}"
      end
      user.confirm!
      user
    end
    print "\n"
    
    # -- Creating channels for networks
    @channels = (0...CHANNEL_COUNT).to_a.map do |n|
      print "\rCreating channels and trackings (#{n+1}/#{CHANNEL_COUNT})"
      channel = Channel.create! do |c|
        c.name = "#channel_#{n}"
        c.network = @networks[rand(@networks.size)]
      end
      
      # Adding random number of users to track the channel with random publicity
      channel_users = []
      (rand(MAX_TRACKINGS_COUNT - 1) + 1).times do
        new_user = User.find(rand(USER_COUNT) + 1) 
        channel_users << new_user unless channel_users.include?(new_user)
      end
      channel_users.each do |user|
        Tracking.create! do |t|
          t.user = user
          t.channel = channel
          t.publicity = ['private','public'][rand(2)]
        end
      end
      channel
    end
    print "\n"
    
    # -- Creating nicks for networks
    NICK_COUNT.times do |n|
      print "\rCreating nicks (#{n+1}/#{NICK_COUNT})"
      Nick.create! do |c|
        c.name = "nick_#{n}"
        c.ident = "ident_#{n}"
        c.host = "host_#{(n % 10)}"
        c.network = @networks[rand(@networks.size)]
      end
    end
    print "\n"
    
    # -- Creating urls and url occureences
    # Creating url objects
    @urls = (0...URL_COUNT).to_a.map do |n|
      Url.create! do |u|
        u.url = "http://www.testurl#{n}.com"
        u.title = "Some URL number #{n}"
        u.status = "checked"
        u.type = [nil, 'ImageUrl', 'VideoUrl'][rand(3)]
      end 
    end

    OCCURRENCE_COUNT.times do |n|
      print "\rCreating url occurrences for #{URL_COUNT} unique urls (#{n+1}/#{OCCURRENCE_COUNT})"
      channel = @channels[rand(@channels.size)]
      occurrence = Occurrence.create! do |o|
        o.url = @urls[rand(@urls.size)]
        o.nick = channel.network.nicks[rand(channel.network.nicks.count)]
        o.channel = @channels[rand(@channels.size)]
        o.created_at = Time.now - n.minutes
        o.updated_at = Time.now - n.minutes
      end
      
      Logging.create! do |l|
        # Creating new URL occurence
        l.user = channel.users.first
        l.occurrence = occurrence
        l.sent_from = rand(100).to_s
        # Set publicity to same as user tracking publicity
        l.publicity = l.user.trackings.find_by_channel_id(channel.id).publicity
      end
    end
    print "\n"
  end
end