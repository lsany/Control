class ApplyPrefJob < ActiveJob::Base
  queue_as :default
  before_perform :CreateCommonPrefJob
  after_perform :make_another_request

  def CreateCommonPrefJob
    users = User.where(present:true)
    @pref_cred_stat = 0
    @num_temp = 0
    @light_0 = false
    @owner_light0 = false
    @light_1 = false
    @owner_light1 = false
    @light_2 = false
    @owner_light2 = false
    @light_3 = false
    @owner_light3 = false

    @flag_present = false

    users.each do |user|
      #occupant detected
      @flag_present = true

      #temperature
      @temp = user.credit_temperature*user.status
      @pref_cred_stat += user.pref_temperature*@temp
      @num_temp += @temp

      #light0....
      if user.credit_light0 == 2
        @light_0 = user.pref_light0
        @owner_light0 = true
      elsif @owner_light0 == false
        @light_0 |= user.pref_light0
      else
        #do nothing
      end

      #light1....
      if user.credit_light1 == 2
        @light_1 = user.pref_light1
        @owner_light1 = true
      elsif @owner_light1 == false
        @light_1 |= user.pref_light1
      else
        #do nothing
      end

      #light2....
      if user.credit_light2 == 2
        @light_2 = user.pref_light2
        @owner_light2 = true
      elsif @owner_light2 == false
        @light_2 |= user.pref_light2
      else
        #do nothing
      end

      #light3....
      if user.credit_light3 == 2
        @light_3 = user.pref_light3
        @owner_light3 = true
      elsif @owner_light3 == false
        @light_3 |= user.pref_light3
      else
        #do nothing
      end


      #light0....
      #@light_0 |= user.pref_light0

      #light1....
      #@light_1 |= user.pref_light1

      #light2....
      #@light_2 |= user.pref_light2

      #light0....
      #@light_3 |= user.pref_light3

    end

    if @num_temp !=0 then
      @pref_cred_stat /=@num_temp
    end

    #update common_preference
    common_user = User.first

    common_user.present = @flag_present

    #update temperature
    common_user.pref_temperature = @pref_cred_stat


    #update light0....
    common_user.pref_light0 = @light_0
    #common_user.pref_light0 = true
    common_user.pref_light1 = @light_1
    common_user.pref_light2 = @light_2
    common_user.pref_light3 = @light_3

    common_user.save

  end

  def perform

    common_user = User.first

    #present
    @flag_present = 0x0

    if common_user.present == true
      @flag_present = 0x1
    end


    ####  air conditioner ####


    #response = HTTParty.get('http://172.31.8.129/tes/1.0/filter.json?ucode=00001C000000000000020000000D4402')
    #data = response.body
    #rev_data = JSON.parse(data).first.first
    #temp_o = rev_data['data']['instance']
    #@temp_o = rev_data['data']


    #Generate target temperature
    if @temp_o == nil
      @temp_o = 15
    end

    ### Calculate the comfort temperature
    if @temp_o > 18||@temp_o==18
      @temp_c = 18.6+0.16*@temp_o
    end
    if @temp_o < 18
      @temp_c = 20.4+0.06*@temp_o
    end
    if common_user.pref_temperature >3||common_user.pref_temperature == 3
      set_point = @temp_c + (common_user.pref_temperature-3)/2*3.5
    end
    if common_user.pref_temperature <3
      set_point = @temp_c + (common_user.pref_temperature-3)/2*1.5
    end

    #Set AC mode
    #response = HTTParty.get('http://172.31.8.129/api/v1/air_conditioners/51.json')

    #data = response.body
    #need .first.first for light
    #rev_data = JSON.parse(data).first.first
    #rev_data = JSON.parse(data)

    header = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Content-Length' => '*'
    }
    on =
        {
            :air_conditioner => {
                :id => 51.to_i,
                :setting_bit => '1010001'.to_i(2),
                #:on_off => 0x0001,
                :on_off => @flag_present,
                :operation_mode => 0x0, #d/c
                :ventilation_mode => 0x0, #d/c
                :ventilation_amount => 0x0,#d/c
                :set_point => set_point.round,
                #:set_point => 23, #d/c
                :fan_speed => 0,#d/c
                :fan_direction => 0,#d/c
                :filter_sign_reset => 0#d/c
            }
        }
    HTTParty.put('http://172.31.8.129/api/v1/air_conditioners/51', :body => on.to_json, :headers => header)

    #### lights ####

    s305light = '00001C000000000000020000000D44F6'
    s305light0 = '00001C000000000000020000000D448A'
    s305light1 = '00001C000000000000020000000D448B'
    s305light2 = '00001C000000000000020000000D448C'
    s305light3 = '00001C000000000000020000000D448D'

    header = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Content-Length' => '*'
    }

    if common_user.pref_light0 == true
      body = [{ucode:s305light0,instance:'on'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    else
      body = [{ucode:s305light0,instance:'off'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    end

    if common_user.pref_light1 == true
      body = [{ucode:s305light1,instance:'on'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    else
      body = [{ucode:s305light1,instance:'off'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    end

    if common_user.pref_light2 == true
      body = [{ucode:s305light2,instance:'on'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    else
      body = [{ucode:s305light2,instance:'off'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    end

    if common_user.pref_light3 == true
      body = [{ucode:s305light3,instance:'on'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    else
      body = [{ucode:s305light3,instance:'off'}]
      HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => body.to_json, :headers => header)
    end


    #reset present information of user
    users = User.all
    users.each do |user|
      user.present = 0
      user.save
    end

    #reset common_user
    common_user.pref_temperature = 0
    common_user.present = 0
    common_user.pref_light0 = 0
    common_user.pref_light1 = 0
    common_user.pref_light2 = 0
    common_user.pref_light3 = 0
    common_user.save
  end


  private
  def make_another_request
    ApplyPrefJob.set(wait: 10.minutes).perform_later
  end
end
