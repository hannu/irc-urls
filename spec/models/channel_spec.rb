require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Channel do
  describe 'allows legitimate channel names:' do
    ['#channel', '!channel', '&channel', '#a', '#a-bc', '!a', '##foobar', "#sPèc-ïäl",
    ].each do |channel_str|
      it "'#{channel_str}'" do
        Channel.new(:name => channel_str, :network => Factory.create(:network)).should be_valid
      end
    end
  end
  
  describe 'disallows illegitimate channel names:' do
    ['ch#annel', 'a', '#spa ce',"#ta\tb", '!', '&', '#', '',
    ].each do |channel_str|
      it "'#{channel_str}'" do
        Channel.new(:name => channel_str, :network => Factory.create(:network)).should_not be_valid
      end
    end
  end
  
  describe 'cleans up channel name correctly:' do
    {'#channel' => 'channel', '#foo#bar' => 'foo#bar', '!chan' => '!chan', '&chan' => '&chan'
    }.each do |original, cleaned|
      it "'#{original}' -> '#{cleaned}'" do
        Channel.clean_name(original).should eql(cleaned)
      end
    end
  end
  
  describe 'fixes channel name correctly:' do
    {'channel' => '#channel', 'foo#bar' => '#foo#bar', '!chan' => '!chan', '&chan' => '&chan'
    }.each do |original, fixed|
      it "'#{original}' -> '#{fixed}'" do
        Channel.real_name(original).should eql(fixed)
      end
    end
  end
end
