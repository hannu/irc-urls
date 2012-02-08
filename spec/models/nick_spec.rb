require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Nick do
  describe 'allows legitimate nick names:' do
    ['nick', 'nick^', 'somenick___', 'foo' 
    ].each do |nick_str|
      it "'#{nick_str}'" do
        build_nick(:name => nick_str).should be_valid
      end
    end
  end
  
  describe 'disallows illegitimate' do
    ['', 'spa ce', "tab\ttab"
    ].each do |str|
      it "nick name: '#{str}'" do
        build_nick(:name => str).should_not be_valid
      end
      
      it "host name: '#{str}'" do
        build_nick(:host => str).should_not be_valid
      end
      
      it "ident: '#{str}'" do
        build_nick(:ident => str).should_not be_valid
      end
    end
  end
  
  private

  def build_nick(options = {})
    Nick.new({
      :name => 'nick',
      :ident => 'ident',
      :host => 'some.imaginary.com',
      :network => Factory.create(:network)
    }.merge(options))
  end
end
