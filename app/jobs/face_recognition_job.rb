class FaceRecognitionJob < ActiveJob::Base
  queue_as :default
  after_perform :make_another_request

  def CreateCommonPrefJob

    time = Time.new
    allusers = User.all
    allusers.each do |user|
      #if time.min.to_i - user.updated_at.min.to_i > 10
      if time.min - user.updated_at.min > 10
        user.present = false
        user.save
      end
    end

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

    users = User.where(present:true)
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
      else
        if @owner_light0 == false
          @light_0 |= user.pref_light0
        end
      end

      #light1....
      if user.credit_light1 == 2
        @light_1 = user.pref_light1
        @owner_light1 = true
      else
        if @owner_light1 == false
          @light_1 |= user.pref_light1
        end
      end

      #light2....
      if user.credit_light2 == 2
        @light_2 = user.pref_light2
        @owner_light2 = true
      else
        if @owner_light2 == false
          @light_2 |= user.pref_light2
        end
      end

      #light3....
      if user.credit_light3 == 2
        @light_3 = user.pref_light3
        @owner_light3 = true
      else
        if @owner_light3 == false
          @light_3 |= user.pref_light3
        end
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

    if @num_temp !=0
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

  def ApplyPref

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

    @body = nil
    if common_user.pref_light0 == true
      @body = [{ucode:s305light0,instance:'on'}]
    else
      @body = [{ucode:s305light0,instance:'off'}]
    end

    if common_user.pref_light1 == true
      @body += [{ucode:s305light1,instance:'on'}]
    else
      @body += [{ucode:s305light1,instance:'off'}]
    end

    if common_user.pref_light2 == true
      @body += [{ucode:s305light2,instance:'on'}]

    else
      @body += [{ucode:s305light2,instance:'off'}]
    end

    if common_user.pref_light3 == true
      @body += [{ucode:s305light3,instance:'on'}]
    else
      @body += [{ucode:s305light3,instance:'off'}]
    end
    HTTParty.put('http://172.31.8.129/tes/1.0/control.json', :body => @body.to_json, :headers => header)

    puts 'New policy applied!'
  end


  def perform
    system '/home/NEC/NeoFace/Test/ScoreCheck'
    self.CreateCommonPrefJob
    self.ApplyPref
  end

  private
  def make_another_request
    FaceRecognitionJob.set(wait: 0.seconds).perform_later
  end
end
