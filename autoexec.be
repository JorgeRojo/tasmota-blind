# https://github.com/arendst/Tasmota/tree/development/tasmota/berry

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
var TEXT_UP = 'UP ▲'
var TEXT_DOWN = 'DOWN ▼' 
var MQTT_TOPIC = tasmota.cmd("status")['Status']['Topic']
var MQTT_TOPIC_UP = "stat/" + MQTT_TOPIC + "/" + RELAY_UP
var MQTT_TOPIC_DOWN = "stat/" + MQTT_TOPIC + "/" + RELAY_DOWN
var DEFAULT_MAX_TURNS = 180 


class TasmotaBlind : Driver
  var turns_max
  var turns_range
  var turns_position
  var relay_direction_check_time
  
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

  def relay_direction_check(topic)
    var can_turn_on = (tasmota.millis() - self.relay_direction_check_time) > 500

    var can_up = can_turn_on && topic == MQTT_TOPIC_UP && 
      self.turns_position == self.turns_max && !tasmota.get_power(0)

    var can_down = can_turn_on && topic == MQTT_TOPIC_DOWN && 
      self.turns_position == 0 && !tasmota.get_power(1)
 
    if can_up  
      print(">>>> relay_direction_check", topic)
      tasmota.cmd("PowerOnState 0")
      tasmota.set_power(0, true)
    end

    if can_down  
      print(">>>> relay_direction_check", topic)
      tasmota.cmd("PowerOnState 0") 
      tasmota.set_power(1, true)
    end
  end

  def off_all()
    self.relay_direction_check_time = tasmota.millis()
    tasmota.cmd("PowerOnState 4")
  end

  def set_turn_range(turns_position, turns_max) 
    self.turns_range = int((int(turns_position) * 100) / int(turns_max))
  end

  def set_turn()
    var is_up = tasmota.get_power(0)
    var is_down = tasmota.get_power(1)
    print(">>>> is_up", is_up)
    print(">>>> is_down", is_down) 

    if is_up && self.turns_position > 0 
      self.set_turns_position(self.turns_position - 1) 
    end
    
    if is_up && self.turns_position <= 0  
      self.set_turns_position(0)
      self.off_all() 
      print(">>>> IS FULL UP") 
    end


    if is_down && self.turns_position < self.turns_max 
      self.set_turns_position(self.turns_position + 1)
    end

    if is_down && self.turns_position >= self.turns_max  
      self.set_turns_position(self.turns_max)
      self.off_all()
      print(">>>> IS FULL DOWN") 
    end
  end
 
  def init()
    self.turns_max = int(persist.find("turns_max", str(DEFAULT_MAX_TURNS)))
    self.turns_position = int(persist.find("turns_position", "0"))
    self.relay_direction_check_time = tasmota.millis()
    self.set_turn_range(self.turns_position, self.turns_max) 

    var current_module = tasmota.cmd("Module")['Module'].find('0')
    var is_module = current_module == MODULE_NAME
    var host_name = tasmota.cmd("status 5")['StatusNET']['Hostname']
    var device_name = MODULE_NAME + '-' + string.replace(host_name, "tasmota-", "") 

    if is_module
      self.off_all()

      # set switch 1 to report state, not toggle
      tasmota.cmd("SwitchMode1 1")
      # disconnect switches from relays
      tasmota.cmd("SetOption114 1")
      # dont report switches state
      tasmota.cmd("SwitchTopic 0")

      # commutate relays to activate only one and automatically turn off the other
      tasmota.cmd("Interlock 1,2") 
      tasmota.cmd("Interlock ON") 
      tasmota.cmd("PowerOnState 0")  
 
      # device texts  
      tasmota.cmd("WebButton1 " + TEXT_UP) 
      tasmota.cmd("WebButton2 " + TEXT_DOWN)
      
    else 
      tasmota.cmd('Template ' + TEMPLATE)
      tasmota.cmd('Module 0')
      tasmota.cmd("DeviceName " + device_name)
      tasmota.cmd("FriendlyName1 " + TEXT_UP)
      tasmota.cmd("FriendlyName2 " + TEXT_DOWN)
    end
  end
 
  def web_add_main_button()
    webserver.content_send("<br/><br/>"
      "<table width='100%'>"
        "<tr>"
          "<td colspan='2'>"
            "<table width='100%'>"
              "<tr>"
                "<td><label for='turns_range'>Open</label></td>"
                "<td style='text-align: right;'><label for='turns_range'>Close</label></td>"
              "</tr>"
            "</table>"
            "<input id='turns_range' type='range' min='0' max='100' value='" + str(self.turns_range) + "' oninput='la(\"&turns_range=\" + value);' />"
          "</td>"
        "</tr>"
        "<tr>"
          "<td width='50%'>"
            "<p><label for='turns_position'>Initial turn:</label></p>"
            "<input id='turns_position' type='number' min='0' max='6000' onChange='la(\"&turns_position=\" + value);' value='" + str(self.turns_position) + "' />"
          "</td>"
          "<td width='50%'>"
            "<p><label for='turns_max'>Máximum turns:</label></p>"
            "<input id='turns_max' type='number' min='1' max='6000' onChange='la(\"&turns_max=\" + value);' value='" + str(self.turns_max) + "' />"
          "</td>"
        "</tr>"
      "</table>"
      "<br/><br/>"  
    )
  end 

  def web_sensor()
    if webserver.has_arg("turns_range")
      var turns_position_to_go = int((int(webserver.arg("turns_range")) * self.turns_max ) / 100)
      print(">>>> turns_position_to_go", turns_position_to_go)  
    end 

    if webserver.has_arg("turns_max")
      self.set_turns_max(webserver.arg("turns_max"))
    end  

    if webserver.has_arg("turns_position")
      self.set_turns_position(webserver.arg("turns_position"))
    end


    var current_turn = str(self.turns_position) + '/' +  str(self.turns_max)
    webserver.content_send(format("{s}Current turn{m}%s{e}", current_turn))
    tasmota.publish("stat/" + MQTT_TOPIC + "/SENSOR", string.format("{\"CurrentTurn\": \"%s\"}", current_turn) ) 

    # mqtt.publish("stat/" + MQTT_TOPIC + "/counter1", current_turn)
  end

end

var blind = TasmotaBlind()
tasmota.add_driver(blind)

# rules and subcirbers
mqtt.unsubscribe(MQTT_TOPIC_UP)
mqtt.subscribe(MQTT_TOPIC_UP, def (topic) blind.relay_direction_check(topic) end)

mqtt.unsubscribe(MQTT_TOPIC_DOWN)
mqtt.subscribe(MQTT_TOPIC_DOWN, def (topic) blind.relay_direction_check(topic) end)

tasmota.remove_rule(SWITCH + "#State=1")
tasmota.add_rule(SWITCH + "#State=1", def () blind.set_turn() end)