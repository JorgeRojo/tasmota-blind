# https://github.com/berry-lang/berry/wiki/Chapter-7#math-module
# https://github.com/berry-lang/berry
# https://github.com/arendst/Tasmota/blob/development/tasmota/berry/examples/web_handler_demo.be
# https://github.com/arendst/Tasmota/blob/development/tasmota/berry/gpio_viewer/debug_panel.be

import mqtt
import math  
import persist
import string  
import webserver

print(">>>>>>>>>> tasmota-blind <<<<<<<<<<")  

var BUTTON_COUNTER = 'Button1'
var BUTTON_COUNTER_DELAY = 10
var RELAY_UP = 'POWER1'
var RELAY_DOWN = 'POWER2'


class TasmotaBlind : Driver
  var turns_max
  var turns_position 
 
  def set_turns_max(value) 
    self.turns_max = int(value) 
    persist.turns_max = value 
    persist.save() 
    print(">>>> set turns_max: ",value)
  end 

  def set_turns_position(value)  
    self.turns_position = int(value)
    persist.turns_position = value 
    persist.save() 
    print(">>>> set turns_position: ", value)
    self.web_add_main_button()
  end

  def init()  
    tasmota.cmd("SetOption32 " + str(BUTTON_COUNTER_DELAY))
    tasmota.cmd("SetOption73 1")
    tasmota.cmd("Backlog ButtonMode 0")
    tasmota.cmd("ButtonTopic 0")

    self.turns_max = int(persist.find("turns_max", "0"))
    self.turns_position = int(persist.find("turns_position", "0"))
  end
 
  def web_add_main_button()
    webserver.content_send("<br/><br/>" +
      "<table width='100%'>" + 
        "<tr>"+ 
          "<td width='50%'>" +
            "<p>" +
              "<label for='turns_position'>"+
                "Current tunrs position:" + 
              "</label>" +
            "</p>" +
            "<input id='turns_position' type='number' min='0' max='6000' onChange='la(\"&turns_position=\" + value);' value='" + str(self.turns_position) + "' />" +
          "</td>" +
        "</tr>" +
        "<tr>"+
          "<td width='50%'>" +
            "<p>" +
              "<label for='turns_max'>"+ 
                "Máximum turn of full closed:" + 
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
      print(">>>> set turns_max: ", webserver.arg("turns_max"))
    end  

    if webserver.has_arg("turns_position")
      self.set_turns_position(webserver.arg("turns_position"))
    end  
  end 

end

d1 = TasmotaBlind() 
tasmota.add_driver(d1)


# ------------------ rule_button_counter ------------------ 
var button_counter_last_update = tasmota.millis()
def rule_button_counter()
  var now = tasmota.millis()
  var update_diff = now - button_counter_last_update

  if update_diff > 100 
    d1.set_turns_position(d1.turns_position + 1)
  end

  button_counter_last_update = now
end
tasmota.add_rule(BUTTON_COUNTER, rule_button_counter) 
# ------------------ rule_button_counter ------------------