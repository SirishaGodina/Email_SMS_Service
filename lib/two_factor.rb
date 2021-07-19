require 'httparty'

class TwoFactor
  include HTTParty

  TWO_FACTOR_API_KEY = 'f6d58176-d4f0-11eb-8089-0200cd936042'

  def self.send_passcode(phone)
    response = HTTParty.get("https://2factor.in/API/V1/#{TWO_FACTOR_API_KEY}/SMS/#{phone}/AUTOGEN2")
    response.parsed_response
  end

  def self.verify_passcode(session_key, code)
    response = HTTParty.get("https://2factor.in/API/V1/#{TWO_FACTOR_API_KEY}/SMS/VERIFY/#{session_key}/#{code}")
    #HTTParty.post("http://2factor.in/API/V1/#{TWO_FACTOR_API_KEY}/SMS/VERIFY3/#{@user.phone_no}/#{@otp}")
    return response.parsed_response
  end
end