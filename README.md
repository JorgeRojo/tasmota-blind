# tasmota IKEA-SCHOTTIS-BLIND

### flash to tasmota32

- https://tasmota.github.io/docs/ESP32/#esp32-s2
- https://tasmota.github.io/docs/ESP32/#flashing
- https://tasmota.github.io/install/
- https://tasmota.github.io/docs/Blinds-and-Shutters
- https://tasmota.github.io/docs/Commands/#shutters
- https://tasmota.github.io/docs/PWM-dimmer-switch/#pwm-dimmer-operation

## S2 mini

![S2 mini](images/image-2.png)
https://www.wemos.cc/en/latest/s2/s2_mini.html#pin

## COMPONENTS

| Component                | Price      | Link                                                                                    | Image                                           |
| ------------------------ | ---------- | --------------------------------------------------------------------------------------- | ----------------------------------------------- |
| Micro-controller esp32s2 | 0,99€      | [aliexpress](https://es.aliexpress.com/item/1005006469381084.html)                      | ![Micro-controller esp32s2](images/image-6.png) |
| Voltage regulator        | 0,46€      | [aliexpress](https://es.aliexpress.com/item/1005005870392716.html)                      | ![Voltage regulator](images/image-5.png)        |
| Motor controller HG7881  | 0,99€      | [aliexpress](https://es.aliexpress.com/item/1005006126762079.html)                      | ![Motor controller HG7881](images/image-7.png)  |
| Micro switcher           | 0,95€      | [aliexpress](https://es.aliexpress.com/item/1005003536527857.html)                      | ![Micro switcher](images/image-8.png)           |
| Rotor 200RPM 12V         | 2,29€      | [aliexpress](https://es.aliexpress.com/item/1005004045108485.html)                      | ![Rotor 200RPM 12V](images/image-9.png)         |
| Power supply 5A 12V      | 4,43€      | [aliexpress](https://es.aliexpress.com/item/1005005626231303.html)                      | ![Power supply 5A 12V](images/image-10.png)     |
| Blockout pleated blink   | 6,99€      | [IKEA](https://www.ikea.com/es/es/p/schottis-estor-plisado-opaco-gris-oscuro-90369507/) | ![Estor plisado opaco](images/image-11.png)     |
| Aluminum profile         | 1,88€      | [manomano](https://www.manomano.es/p/pa-24801490)                                       | ![Perfil de Aluminio](images/image-13.png)      |
| Nylon rope 1mm           | 1,84€      | [aliexpress](https://es.aliexpress.com/item/1005001826069499.html)                      | ![Cuerdad de nylon 1mm](images/image-14.png)    |
| Case                     | 1,90€      | [aliexpress](https://es.aliexpress.com/item/1005002656761229.html)                      | ![Case](images/image-15.png)                    |
| Epoxy paste              | 3,10€      | [aliexpress](https://es.aliexpress.com/item/1005006124394766.html)                      | ![Epoxy paste](images/image-16.png)             |
| Total:                   | **25,82€** |                                                                                         |                                                 |

## Copilot helped me

... my question was:

**Given my 12V power supply rated at 5A, how many 12V motors (each drawing 0.34A) and ESP32 devices (each drawing approximately 0.1A) can I connect?**

... copilot answered:

**With a 12V power supply rated at 5A, we can calculate how many 12V motors (each drawing 0.34A) and ESP32 devices (each drawing approximately 0.1A) you can connect. Here’s the breakdown:**

- Total current per device:
  - Motor: **0.34A**
  - ESP32: Approximately **0.1A**
- Total current per device:
  - **0.34A (motor) + 0.1A (ESP32) = 0.44A**
- Maximum number of motors and ESP32 devices:
  - The power supply provides a total of **5A**.
  - Divide the total power supply current by the total current per device:
  - **5A / 0.44A ≈ 11**
  - Therefore, you can connect up to **11 motors** and **11 ESP32 devices** to your power supply.
