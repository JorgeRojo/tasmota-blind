import mqtt
import math  
import persist
import string  
import webserver
 
var MODULE_NAME = 'IKEA-SCHOTTIS-BLIND'
var TEMPLATE = '{"NAME":"' + MODULE_NAME + '","GPIO":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,288,0,0,0,0,0,224,0,225,0,0,0,0,0,160,0,0,0,0,0,0],"FLAG":0,"BASE":1}'
var SWITCH = 'Switch1'
var RELAY_UP = 'POWER1'
var RELAY_DOWN = 'POWER2'
var DEFAULT_MAX_TURNS = 180



class TasmotaBlind : Driver
  var turns_max
  var turns_position  
   

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
    tasmota.cmd(SWITCH + ' 0') 
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

  def set_turn()
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
    return power_size == 2  
  end

  def init()
    self.turns_max = int(persist.find("turns_max", str(DEFAULT_MAX_TURNS)))
    self.turns_position = int(persist.find("turns_position", "0"))

    var current_module = tasmota.cmd("Module")['Module'].find('0')
    var is_module = current_module == MODULE_NAME

    if is_module
      self.off_all()

      # set switch 1 to report state, not toggle
      tasmota.cmd("SwitchMode1 1");
      # disconnect switches from relays
      tasmota.cmd("SetOption114 1");
      # dont report switches state
      tasmota.cmd("SwitchTopic 0");

      # commutate relays to activate only one and automatically turn off the other
      tasmota.cmd("Interlock ON") 

      # device texts 
      var up = 'UP ▲'
      var down = 'DOWN ▼'


      var host_name = tasmota.cmd("status 5")['StatusNET']['Hostname']
      var device_name = MODULE_NAME + '-' + host_name

      tasmota.cmd("DeviceName " + device_name)
      
      tasmota.cmd("FriendlyName1 " + device_name + ' ' + up)
      tasmota.cmd("WebButton1 " + up)

      tasmota.cmd("FriendlyName2 " + device_name + ' ' + down)
      tasmota.cmd("WebButton2 " + down)
    else 
      tasmota.cmd('Template ' + TEMPLATE)
      tasmota.cmd('Module 0')
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

var blind = TasmotaBlind()
tasmota.add_driver(blind)

# rules --------------------------
tasmota.remove_rule(RELAY_UP)
tasmota.add_rule(RELAY_UP, def () blind.check_turns() end )

tasmota.remove_rule(RELAY_DOWN)
tasmota.add_rule(RELAY_DOWN, def () blind.check_turns() end ) 

tasmota.remove_rule(SWITCH + "#State=1")
tasmota.add_rule(SWITCH + "#State=1", def () blind.set_turn() end)