require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'spec_helper.rb')

describe APN::Notification do
  
  describe 'alert' do
    
    it 'should trim the message to 150 characters' do
      noty = APN::Notification.new
      noty.alert = 'a' * 200
      noty.alert.should == ('a' * 147) + '...'
    end
    
  end
  
  describe 'apple_hash' do
    
    it 'should return a hash of the appropriate params for Apple' do
      noty = APN::Notification.first
      noty.apple_hash.should == {"aps" => {"badge" => 5, "sound" => "my_sound.aiff", "alert" => "Hello!"},"typ" => "1"}
      noty.custom_properties = nil
      noty.apple_hash.should == {"aps" => {"badge" => 5, "sound" => "my_sound.aiff", "alert" => "Hello!"}}
      noty.badge = nil
      noty.apple_hash.should == {"aps" => {"sound" => "my_sound.aiff", "alert" => "Hello!"}}
      noty.alert = nil
      noty.apple_hash.should == {"aps" => {"sound" => "my_sound.aiff"}}
      noty.sound = nil
      noty.apple_hash.should == {"aps" => {}}
      noty.sound = true
      noty.apple_hash.should == {"aps" => {"sound" => "1.aiff"}}
    end
    
  end
  
  describe 'to_apple_json' do
    
    it 'should return the necessary JSON for Apple' do
      noty = APN::Notification.first
      noty.to_apple_json.should == %{{"aps":{"alert":"Hello!","badge":5,"sound":"my_sound.aiff"},"typ":"1"}}
    end
    
  end
  
  describe 'message_for_sending' do
    
    it 'should create a binary message to be sent to Apple' do
      noty = APN::Notification.first
      noty.custom_properties = nil
      noty.device = DeviceFactory.new(:token => '9eebf98d 02a41a4d 93e20f53 16341b1a 81528bad 86059d9e 17f373b1 4e555527')
      noty.message_for_sending.should == fixture_value('message_for_sending.bin')
    end
    
    it 'should raise an APN::Errors::ExceededMessageSizeError if the message is too big' do
      noty = NotificationFactory.new(:device_id => DeviceFactory.create, :sound => true, :badge => nil)
      noty.send(:write_attribute, 'alert', 'a' * 183)
      lambda {
        noty.message_for_sending
      }.should raise_error(APN::Errors::ExceededMessageSizeError)
    end
    
  end
  
  describe 'send_notifications' do 
    
    it 'should warn the user the method is deprecated and call the corresponding method on APN::App' do
      ActiveSupport::Deprecation.should_receive(:warn)
      APN::App.should_receive(:send_notifications)
      APN::Notification.send_notifications
    end
  end
  
end