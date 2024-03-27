import mqtt
import webserver

print(">>>>>>>>>> tasmota-blind <<<<<<<<<<")  

var BUTTON_COUNTER = 'Button1'
var BUTTON_COUNTER_DELAY = 10
var RELAY_UP = 'POWER1'
var RELAY_DOWN = 'POWER2'

tasmota.cmd("SetOption32 " + str(BUTTON_COUNTER_DELAY))
tasmota.cmd("SetOption73 1")
tasmota.cmd("Backlog ButtonMode 0")
tasmota.cmd("ButtonTopic 0")
 


class TasmotaBlind : Driver
  var turn_counter 
  var last_update

  def init()
    self.turn_counter = 0
    self.last_update = tasmota.millis()  
  end
 
  def web_add_main_button()
    webserver.content_send(
      "<p></p>" + 
      "<input type=\"number\" onchange='la(\"&turn_max=1\");'>"
    )
  end


  def web_sensor()

    if webserver.has_arg("turn_max")
      print("turn_max " +   webserver.has_arg("turn_max"))
    end
 
  end

end

d1 = TasmotaBlind() 
tasmota.add_driver(d1)


# ------------------ rule_button_counter ------------------
def rule_button_counter()
  var millis = tasmota.millis()
  var diff = millis - d1.last_update
  d1.last_update = millis

  if diff > 30
    d1.turn_counter = d1.turn_counter + 1
    print(">>>> counter", d1.turn_counter, diff)
  end
end
tasmota.add_rule(BUTTON_COUNTER, rule_button_counter) 
# ------------------ rule_button_counter ------------------