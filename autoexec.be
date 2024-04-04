# https://github.com/arendst/Tasmota/tree/development/tasmota/berry

import math  
import persist
import string  
import webserver
import gpio

var MODULE_NAME = 'IKEA-SCHOTTIS-BLIND-3' 
var TEMPLATE = '{"NAME":"' + MODULE_NAME + '","GPIO":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,224,0,225,0,0,0,0,0,0,0,0,0,0,0,0],"FLAG":0,"BASE":1}'
var DEFAULT_DURATION = 20
 
class TasmotaBlind : Driver

  def set_open_duration(value)
    tasmota.cmd("ShutterOpenDuration1 " + str(value)) 
  end

  def set_close_duration(value)
    tasmota.cmd("ShutterCloseDuration1 " + str(value)) 
  end

  def get_current_position()
    return str(tasmota.cmd("ShutterPosition1")['Shutter1']['Position'])
  end

  def set_initial_position(value)
    tasmota.cmd("PowerOnState 4")

    var position = int(value) 

    var open_duration = str(tasmota.cmd("ShutterOpenDuration1")['ShutterOpenDuration1'])
    var close_duration = str(tasmota.cmd("ShutterCloseDuration1")['ShutterCloseDuration1'])

    tasmota.cmd("ShutterOpenDuration1 1")
    tasmota.cmd("ShutterCloseDuration1 1") 
    tasmota.cmd("ShutterPosition1 " + str(position))

    tasmota.set_timer(2000, 
      def ()
        tasmota.cmd("ShutterOpenDuration1 " + open_duration)
        tasmota.cmd("ShutterCloseDuration1 " + close_duration)
        tasmota.cmd("PowerOnState 0")
      end 
    )
  end

  def init() 
    var current_module = tasmota.cmd("Module")['Module'].find('0')
    var is_module = current_module == MODULE_NAME
    var host_name = tasmota.cmd("status 5")['StatusNET']['Hostname']
    var device_name = MODULE_NAME + '-' + string.replace(host_name, "tasmota-", "")

    if is_module
      print(">>>> init TasmotaBlind module")

      # commutate relays to activate only one and automatically turn off the other
      tasmota.cmd("Interlock 1,2") 
      tasmota.cmd("Interlock ON")
   
      # set shutter mode
      tasmota.cmd("SetOption80 1")
      tasmota.cmd("ShutterMode 1")

      var open_duration = int(tasmota.cmd("ShutterOpenDuration1")['ShutterOpenDuration1'])
      var close_duration = int(tasmota.cmd("ShutterCloseDuration1")['ShutterCloseDuration1'])
      tasmota.cmd("ShutterOpenDuration1 " + str(open_duration < 10 ? DEFAULT_DURATION : open_duration))
      tasmota.cmd("ShutterCloseDuration1 " + str(close_duration < 10 ? DEFAULT_DURATION : close_duration))
    else 
      tasmota.cmd('Template ' + TEMPLATE)
      tasmota.cmd('Module 0')
      tasmota.cmd("DeviceName " + device_name)   
      tasmota.cmd("FriendlyName1 UP ▲")
      tasmota.cmd("FriendlyName2 DOWN ▼")
    end
  end

  def web_add_main_button()
    var open_duration = str(tasmota.cmd("ShutterOpenDuration1")['ShutterOpenDuration1'])
    var close_duration = str(tasmota.cmd("ShutterCloseDuration1")['ShutterCloseDuration1'])
    var initial_position = self.get_current_position()

    webserver.content_send( 
      "<style>"
        ".my_jr_table{"
          "border-collapse: collapse;"
          "width: 100%;"
          "margin: 0 0 16px 0;"
          "border: dotted 5px;"
          "border-radius: 10px;"
          "overflow: hidden;"
          "background-color: rgba(255,255,255, 0.05);"
        "}"
        ".my_jr_table > tr > td , "
        ".my_jr_table > tbody > tr > td {"
          "padding: 8px;"
          "border: dotted 1px rgba(255,255,255, 0.5);"
        "}"
        ".my_jr_input{"
          "border: none;"
          "border-radius: 5px;"
        "}"
        ".text_right {"
          "text-align: right;"
        "}"
      "</style>"
      "<h3>Calibration:</h3>"
      "<table class='my_jr_table'>"
        "<tr>"
          "<td width=33%'>"
            "<p><label for='open_duration'>Open duration secs.:</label></p>"
            "<input class='my_jr_input' id='open_duration' type='number' min='1' max='6000' onChange='la(\"&open_duration=\" + value);' value='" + open_duration + "' />"
          "</td>"
          "<td width='33%'>"
            "<p><label for='close_duration'>Close duration secs.</label></p>"
            "<input class='my_jr_input' id='close_duration' type='number' min='1' max='6000' onChange='la(\"&close_duration=\" + value);' value='" + close_duration + "' />"
          "</td>" 
          "<td width='33%'>"
            "<p><label for='initial_position'>Position %:</label></p>"
            "<input class='my_jr_input' id='initial_position' type='number' min='0' max='100' onChange='la(\"&initial_position=\" + value);' value='" + initial_position + "' />"
          "</td>"
        "</tr>"
        
      "</table>" 
    )
  end 

  def web_sensor()
    if webserver.has_arg("open_duration")
      tasmota.cmd("ShutterOpenDuration1 " + webserver.arg("open_duration"))
    end

    if webserver.has_arg("close_duration")
      tasmota.cmd("ShutterCloseDuration1 " + webserver.arg("close_duration")) 
    end 

    if webserver.has_arg("initial_position") 
      var position = webserver.arg("initial_position")
      self.set_initial_position(position)
    end 
  
  end

end

var blind = TasmotaBlind()
tasmota.add_driver(blind)