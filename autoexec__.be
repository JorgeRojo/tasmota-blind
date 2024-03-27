import math  
import persist
import string  
import webserver  

var RELAY_UP = 'POWER1'
var RELAY_DOWN = 'POWER2'
var COUNTER_BUTTON = 'Switch20'
var POSITION_REGULATOR = 'Dimmer#STATE'


class MyButtonMethods
  var turns_max
  var turns_position

  def set_turns_max(max) {
    self.turns_max = int(max) 
    persist.turns_max = webserver.arg("turns_max") 
    persist.save() 
    print(">>>> set turns_max: ", self.turns_max )
  }

  def set_turns_position(position) {
    self.turns_position = int(position) 
    persist.turns_position = webserver.arg("turns_position") 
    persist.save() 
    print(">>>> set turns_position: ", self.turns_position )
  }

  def init() 
    self.turns_max = int(persist.find("turns_max", "0"))
    self.turns_position = int(persist.find("turns_position", "0"))
  end
 
  def web_add_main_button()
    webserver.content_send("<br/><br/>" +
      "<table width='100%'><tr>"+
        "<td>" +
          "<label for='turns_max'>"+
            "<p>Máximum turn of full closed:  </p> " + 
          "</label>" +
        "</td>" +
        "<td width='50%'>" +
          "<input id='turns_max' type='number' min='1' max='6000' onChange='la(\"&turns_max=\" + value);' value='" + str(self.turns_max) + "' />" +
        "</td>" +      
        "<td>" +
        "<label for='turns_position'>"+
            "<p>Current tunrs position:  </p> " + 
          "</label>" +
        "</td>" +
        "<td width='50%'>" +
          "<input id='turns_position' type='number' min='0' max='6000' onChange='la(\"&turns_position=\" + value);' value='" + str(self.turns_position) + "' />" +
        "</td>" +
      "</tr></table>"+
      "<br/><br/>"  
    )
  end 

  def web_sensor()
    if webserver.has_arg("turns_max") 
      self.set_turns_position(webserver.arg("turns_max"))
    end  

    if webserver.has_arg("turns_position")
      self.set_turns_position(webserver.arg("turns_position"))
    end  
  end 
end

driver1 = MyButtonMethods()
tasmota.add_driver(driver1)

 

def counter_button_rule()
  var counter = driver1.turns_position + 0.5 

  if driver1.turns_max >= counter
    driver1.set_turns_position(counter) 
  end

  if counter <= 0
    driver1.set_turns_position(0)  
  end
  
end  
tasmota.add_rule(COUNTER_BUTTON, counter_button_rule)

# 
# 
# var turns_to_go = int(persist.find("turns_to_go", "0"))
# def dimmer_rule(value)
#   
#   tasmota.set_power(0, true)
#   tasmota.set_power(1, false) 
#   tasmota.set_power(2, false) 
# 
#   turns_to_go = value
# 
#   persist.turns_to_go = str(turns_position) 
#   persist.save()
# 
#   print(">>>> set turns_to_go: ", turns_to_go )
# end  
#  
# 
# print(">>>> ini revolutions: ", d1.revolutions )
# print(">>>> ini turns_position: ", turns_position )
# print(">>>> ini turns_to_go: ", turns_to_go )
# 
#  
# 
# def relay_rule(value, trigger)
#   
#   var is_on =  value["State"] == 1
# 
#   if trigger == 'POWER1' && is_on 
#     tasmota.set_power(2, false)
#   end
# 
#   if trigger == 'POWER2' && is_on 
#     tasmota.set_power(1, false)
#   end
# 
#   print(">>>> POWER ", tasmota.get_power())
# 
# end
# 
#  
# tasmota.set_power(0, true)
# tasmota.set_power(1, false)
# tasmota.set_power(2, false) 
# tasmota.cmd("Dimmer " + str(turns_to_go))
# 
# 
# tasmota.add_rule("POWER1", relay_rule)
# tasmota.add_rule("POWER2", relay_rule)
# tasmota.add_rule("Switch20", button_rule)
# tasmota.add_rule("Dimmer#STATE", dimmer_rule)