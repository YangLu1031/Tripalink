require 'cgi'
require 'rest_client'
require 'open-uri'
require 'nokogiri'

module CarsHelper
  class VINFetcher
    def initialize
      @email = "397703407@QQ.COM"
      @password = "397703407qq"
      plate = "6RBU987"  #params["plate"]
      state = "CA"  #params["state"]
      timestamp = "1434419840000"
      #@signature = "9548b3095b1219e641cad76c1c579247282c7d52b650c06ac574a7df09b56661e57a4eb5dcd2f6c1b3c6e65e0616a90fb58fae3a4e57d7a661407252384747be"
      @signature = ENV["carfax_signature"]
    end

    def fetchVINWithPlate(plate = "6RBU987", state="CA")
      # debugger
      (1..3).each { |trialno|
        if @signature == nil
          login
        end
        timestamp = (Time.now.getutc.to_i*1000).to_s
        url = "https://secured.carfax.com/traveler-api/quickvin/lookup.json?email=%s&timestamp=%s&signature=%s&plate=%s&state=%s" % [CGI.escape(@email), timestamp, @signature, CGI.escape(plate), CGI.escape(state)]
        puts '='*20 + "Trial NO. %s" % trialno.to_s
        puts url
        puts eval(ENV["carfax_cookies"])
        j = nil
        headers = {"Referer" => "https://secured.carfax.com/showroom/main.cfx",
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:38.0) Gecko/20100101 Firefox/38.0",
          :cookies => eval(ENV["carfax_cookies"])
        }
        begin
          j = JSON.parse(RestClient.get(url, headers))
          if j && j["quickVinResults"] && j["quickVinResults"][0] && j["quickVinResults"][0]["vin"]
            return j["quickVinResults"][0]["vin"]
          end
        rescue => err
          puts '='*20 + "Failed trial No. %s" % trialno.to_s
          puts err.message
          #puts err.backtrace
          login
        end
      }
      nil
    end

    def fetchModelIdWithVIN(vin="WBAKG7C51DJ437538")
      url = 'https://api.edmunds.com/v1/api/toolsrepository/vindecoder?vin=%s&fmt=json&api_key=v7nh772a4fe88gm3atabxnp4' % vin
      j = nil
      begin
        j = JSON.parse(open(url).read)
      rescue => err
        puts err.message
        puts err.backtrace
      end

      styleId = j['styleHolder'][0]['id']
    end

    def login
      url = "https://secured.carfax.com/showroom/login.cfx"
      params = '{"username":"%s","password":"%s"}' % [@email, @password]
      r = RestClient.post url, params, :content_type => 'application/json'
      url = "https://secured.carfax.com/showroom/main.cfx"
      token = nil
      begin
        token = JSON.parse(r)
      rescue => err
      end
      cookies = r.cookies.dup
      cookies["CFX_TOKEN"] = token["cfx_token"]
      html = RestClient.get(url,
        {:cookies => cookies})
      html.cookies.each do |key, value|
        cookies[key] = value
      end
      noko = Nokogiri::HTML(html)
      sig = noko.xpath '//div[@id="RunBox"]//form[@id="runByPlateStateForm"]/input[@id="signatureInput"]'
      if sig == nil || sig.size < 1
        puts "Could not find input signatureInput in runByPlateStateForm."
        return nil
      end
      ENV["carfax_signature"] = @signature = sig[0].attribute('value').value
      ENV["carfax_cookies"] = cookies.inspect
    end

  end


end
