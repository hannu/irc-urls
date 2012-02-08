class Submission
  attr_reader :nick, :ident, :host, :url, :sent_at, :tracking_id, :sent_from

  def initialize(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def tracking
    @tracking ||= Tracking.find(tracking_id)
  end

  def perform
    Logging.transaction do
      Logging.create!(:user => tracking.user, :occurrence => occurrence, :publicity => tracking.publicity, :sent_from => sent_from)
    end
  end

  private

  def occurrence
    u = Url.find_or_initialize_by_url(url, :status => "unchecked")
    if u.new_record?
      u.save!
      u.delay.process
    end

    n = db_nick

    tracking.channel.occurrences.posted_around(sent_at).first(
      :conditions => {:nick_id => n.id, :url_id => u.id}
    ) ||
    tracking.channel.occurrences.create!(
      :nick => n,
      :url => u,
      :created_at => sent_at
    )
  end

  def db_nick
    # Find if nick already exists
    tracking.channel.network.nicks.first(
      :conditions => {:name => nick, :host => host, :ident => ident}
    ) || # Nick not found. Create new nick 
    Nick.create!(
      :name => nick,
      :host => host,
      :ident => ident, 
      :network => tracking.channel.network
    )
  end
end
