class Sms < ActiveRecord::Base
  belongs_to :user

  def delivery!
    require 'rest_client'
    puts "Sending Sms via NetFun"
    uri       = NETFUN_DATA[:host]
    post_args = { :smsTEXT => content,
      :smsSENDER => "SeiConnesso.org",
      :smsNUMBER => user.phone,
      :smsGATEWAY => "1",
      :smsTYPE => "file.sms",
      :smsUSER => NETFUN_DATA[:username],
      :smsPASSWORD => NETFUN_DATA[:password]
    }
    if Rails.env == "production"
      logger.info "Sending SMS to #{user.phone} with content #{content}"
      a = RestClient.post uri, post_args
      self.update_attribute :callback_result, a.to_yaml
      puts a.to_yaml
      if a.first == "+"
        self.update_attribute :processed, true
      end
    else
      logger.info post_args
      self.update_attribute :processed, true
    end
  end
end
