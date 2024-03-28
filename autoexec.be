import mqtt
import math  
import persist
import string  
import webserver

print(">>>>>>>>>> tasmota-blind <<<<<<<<<<")  

var TEMPLATE = '{"NAME":"tasmota-blind","GPIO":[0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,288,0,0,0,0,0,224,0,225,0,0,0,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}'
var BUTTON_COUNTER = 'Button1'
var BUTTON_COUNTER_DELAY = 10
var DEFAULT_MAX_TURNS = 180
var RELAY_UP = 'POWER1'
var RELAY_DOWN = 'POWER2'


class TasmotaBlind : Driver
  var turns_max
  var turns_position 
  var turns_counter_last_update 

  def rule_button_counter()
    var now = tasmota.millis()
    var update_diff = now - self.turns_counter_last_update
  
    if update_diff > 10 
      self.ser_turn()
      self.turns_counter_last_update = now
    end
  end

  def set_turns_max(value) 
    self.turns_max = int(value) 
    persist.turns_max = value 
    persist.save() 
    print(">>>> set turns_max: ", value)
  end 

  def set_turns_position(value)  
    self.turns_position = int(value)
    persist.turns_position = value 
    persist.save() 
    print(">>>> set turns_position: ", value)
  end

  def off_all() 
    tasmota.set_power(0, false) 
    tasmota.set_power(1, false) 
  end

  def check_turns()
    var is_up = tasmota.get_power(0)
    var is_down = tasmota.get_power(1)

    print(">>>> is_up", is_up)
    print(">>>> is_down", is_down) 

    if is_up && self.turns_position <= 0  
        self.set_turns_position(0)
        self.off_all() 
        print(">>>> IS FULL UP") 
    end

    if is_down && self.turns_position >= self.turns_max  
      self.set_turns_position(self.turns_max)
      self.off_all()
      print(">>>> IS FULL DOWN") 
    end
    
  end

  def ser_turn()
    var is_up = tasmota.get_power(0)
    var is_down = tasmota.get_power(1)

    if is_up && self.turns_position > 0 
      self.set_turns_position(self.turns_position - 1) 
    end

    if is_down && self.turns_position < self.turns_max 
      self.set_turns_position(self.turns_position + 1)
    end
    
    self.check_turns()
  end


  def has_template()
    var power_size =  tasmota.get_power().size()
    var option32 = tasmota.get_option(32)
    var option73 = tasmota.get_option(73)
    return power_size == 2 && option32 == BUTTON_COUNTER_DELAY && option73 == 0
  end

  def init()
    if self.has_template() 
      tasmota.cmd("Interlock ON")
      self.off_all()
      self.turns_max = int(persist.find("turns_max", str(DEFAULT_MAX_TURNS)))
      self.turns_position = int(persist.find("turns_position", "0"))
      self.turns_counter_last_update = tasmota.millis()
    else 
      tasmota.cmd('Template ' + TEMPLATE )  
      tasmota.cmd("SetOption32 " + str(BUTTON_COUNTER_DELAY))
      tasmota.cmd("SetOption73 0")
      tasmota.cmd("Backlog ButtonMode 0")
      tasmota.cmd("ButtonTopic 0")
      tasmota.cmd("WebButton1 UP ▲")
      tasmota.cmd("WebButton2 DOWN ▼")
      tasmota.cmd("Restart 1")
    end
  end
 
  def web_add_main_button()
    webserver.content_send("<br/><br/>" +
      "<table width='100%'>" + 
        "<tr>"+ 
          "<td width='50%'>" +
            "<p>" +
              "<label for='turns_position'>"+
                "Current turn:" + 
              "</label>" +
            "</p>" +
            "<input id='turns_position' type='number' min='0' max='6000' onChange='la(\"&turns_position=\" + value);' value='" + str(self.turns_position) + "' />" +
          "</td>" +   
          "<td width='50%'>" +
            "<p>" +
              "<label for='turns_max'>"+ 
                "Máximum turns:" + 
              "</label>" +
            "</p>" +
            "<input id='turns_max' type='number' min='1' max='6000' onChange='la(\"&turns_max=\" + value);' value='" + str(self.turns_max) + "' />" +
          "</td>" +   
        "</tr>" +  
      "</table>"+
      "<br/><br/>"  
    )
  end 

  def web_sensor()
    if webserver.has_arg("turns_max")
      self.set_turns_max(webserver.arg("turns_max"))
    end  

    if webserver.has_arg("turns_position")
      self.set_turns_position(webserver.arg("turns_position"))
    end  
  end 

end

var tasmota_blind = TasmotaBlind()

tasmota.add_driver(tasmota_blind)

tasmota.add_rule(RELAY_UP, def () tasmota_blind.check_turns() end )
tasmota.add_rule(RELAY_DOWN, def () tasmota_blind.check_turns() end )
tasmota.add_rule(BUTTON_COUNTER, def () tasmota_blind.rule_button_counter() end )