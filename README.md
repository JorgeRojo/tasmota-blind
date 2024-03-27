# tasmota-blind

tasmota-blind

## berry script

https://tasmota.github.io/docs/Berry/

---

https://tasmota.github.io/docs/Buttons-and-Switches/#rules

SetOption73 1;

Backlog ButtonMode 1;
ButtonTopic 0;
Backlog Rule1 on Button1#state do Publish stat/custom-topic/BUTTON1 %value% endon;
Rule1 1;
Restart 1;

---

{"NAME":"tasmota-blind","GPIO":[1,1,32,1,1,1,1,1,1,1,1,1,1,1,1,288,1,1,1,1,1,225,1,226,1,1,1,1,1,1,1,1,1,1,1,1],"FLAG":0,"BASE":1}
