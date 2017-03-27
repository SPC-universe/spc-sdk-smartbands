# Documentación sdk-smartbands-android

Esta es la documentación de la librería sdk-smartbands-android.

* [WristBandDevice](#wristbanddevice)
* [CallbackHandler](#callbackhandler)
* [Datos](#datos)

## WristBandDevice
Esta clase tiene dos funciones claras, una es la búsqueda de dispositivos y conexión, la otra es realizar las llamadas y devolver los resultados mediante el CallbackHandler que se le asigne.

### Proceso de conexión

* Escanear dispositivos con el comando `startLeScan`.
* Una vez encontrado el dispositivo deseado registrarlo mediante el comando `setBluetoothDevice`.
* Conectarse al dispositivo registrado usando el comando `connect`.

### Métodos públicos

#### WristBandDevice getInstance(Context context)
Método para recuperar la instancia en caso de que exista, sino, la crea.
* Context context: Contexto de la aplicación.

#### void setCallbackHandler(CallbackHandler callbackHandler)
Añade un callback para las respuestas del dispositivo.
* CallbackHandler callbackHandler: Objeto mediante el cual se recibirán las respuestas del dispositivo a los comandos enviados.

#### BluetoothDevice getBluetoothDevice()
Devuelve el dispositivo registrado.

#### void setBluetoothDevice(BluetoothDevice bluetoothDevice)
Registra un dispositivo
* BluetoothDevice bluetoothDevice: Dispositivo a registrar.

#### void startLeScan(long scanPeriod)
Inicia el proceso de escanear dispositivos para encontrar los que están alrededor.
* long scanPeriod: Tiempo de escaneo en mili segundos.

#### void stopLeScan()
Para el proceso de escanear dispositivos para encontrar.

#### void findToConnect(long scanPeriod)
Inicia el proceso de escanear dispositivos para encontrar el dispositivo registrado y conectarse a el.
* long scanPeriod: Tiempo de escaneo en mili segundos.

#### void stopFindToConnect()
Para el proceso de escanear dispositivos para conectar.

#### boolean isConnected()
Devuelve si el dispositivo está conectado. 

#### boolean connect()
Conecta con el dispositivo asignado, devuelve si ha podido  iniciar la conexión con el dispositivo.

#### void disconnect()
Cierra la conexión con el dispositivo.

#### void getDeviceInfo()
Envía el comando para obtener la información del dispositivo.

#### void getPower()
Envía el comando para obtener el porcentaje de batería.

#### void restart()
Envía el comando para reiniciar el dispositivo.

#### void setDate()
Envía la fecha actual al dispositivo para establecerla.

#### void setAlarm(int id, boolean smart, int week, int hour, int min)
Añade una nueva alarma al dispositivo.
* int id: Id de la alarma.
* boolean smart: SMART???.
* int week: Días de la semana en los que sonará y si se va a repetir. Week es un tipo de dato que necesita de una [explicación más exhaustiva](#week).
* int hour: 0...23 Hora.
* int min: 0...59 Minuto.

#### void getAlarm(int id)
Envía el comando para obtener una alarma con un id concreto.
* int id: id de la alarma.

#### void setSedentaryReminder(Integer index, Integer startHour, Integer endHour, Integer week, Integer minutes, Integer goal)
Añade una alarma sedentaria, en caso de no realizar los movimientos establecidos suena una alarma.
* Integer index: 0...2 Índice de la alarma sedentaria. 
* Integer startHour: 0...23 Hora de inicio.
* Integer endHour: 0...23 Hora de fin.
* Integer week: Días de la semana en los que sonará y si se va a repetir. Week es un tipo de dato que necesita de una [explicación más exhaustiva](#week).
* Integer minutes: Cantidad de bloques de 5 minutos. Ej 1 = 5 minutos, 2 = 10 minutos.
* Integer goal: Objetivo.

#### void getSedentaryReminder()
Devuelve las alarmas sedentarias del dispositivo.

#### void setOptions(boolean light, boolean gesture, boolean unitType, boolean time, boolean sleep, boolean adv, int backLightStartTime, int backLightEndTime, boolean color, boolean language, boolean disconnect)
Establece las opciones en el dispositivo.
* boolean light: Habilitar luz LED.
* boolean gesture: Habilitar control de gestos.
* boolean unitType: true unidad de medida en inglés, false unidad de medida en Chino.
* boolean time: true día 12h, false día 24h.
* boolean sleep: true modo sueño automático, false modo sueño manual.
* boolean adv: Habilitar aviso al conectar.
* int backLightStartTime: 0...23 Hora de inicio de la luz de atrás.
* int backLightEndTime: 0...23 Hora de fin de la luz de atrás.
* boolean color: Color de fondo, false negro, true blanco.
* boolean language: True chino, false inglés.
* boolean disconnect: Disconnect tip true on false off.

#### void getOptions()
Devuelve la configuración de las opciones en el dispositivo.

#### void getSupportedSports()
Devuelve los deportes que el dispositivo puede cargar. [Listado de posibles deportes](#deportes).

#### void setSports(int day, LinkedHashMap\<Integer, Integer> goals)
Carga los deportes que se pueden realizar el día indicado.
* int day: día. 0 domingo, 1 sábado, 2 viernes, 3 jueves, 4 miércoles, 5 martes, 6 lunes.
* LinkedHashMap\<Integer, Integer> goals: Array ordenado de los deportes con sus objetivos, el primer deporte siempre ha de ser el id 1, un máximo de 5 deportes.
  * Primer Integer: Id del deporte.
  * Segundo Integer: Objetivo en pasos.

#### void setSchedule(int year, int month, int day, int hour, int minute, String title)
Añade un recordatorio al calendario.
* int year: 2000... Año.
* int month: 0...11 Mes.
* int day: 0...30 Día.
* int hour: 0...23 Hora.
* int minute: 0...59 Minuto.
* String title: Título del calendario, máximo 7 caracteres.

#### void clearAllSchedules()
Borra todos los recordatorios del calendario.

#### void closeSchedule(int year, int month, int day, int hour, int minute)
Borra un recordatorio en concreto del calendario.
* int year: 2000... Año.
* int month: 0...11 Mes.
* int day: 0...30 Día.
* int hour: 0...23 Hora.
* int minute: 0...59 Minuto.

#### void setUserInfo(int height, int weight, boolean gender, int age, int goal)
Establece la información del usuario en el dispositivo.
* int height: 0...255 Altura.
* int weight: 0...255 Peso.
* boolean gender: true hombre, false mujer.
* int age: 0...255 Edad.
* int goal: Objetivo en pasos.

#### void getUserInfo()
Devuelve la información del usuario establecida en el dispositivo.

#### void syncActivityData(boolean sync)
Inicia la sincronización de actividad con el dispositivo.
* boolean sync: True activar sincronización, false desactivar sincronización.

#### void syncCurrentData(boolean sync)
Inicia la sincronización de la actividad total con el dispositivo.
* boolean sync: True activar sincronización, false desactivar sincronización.

#### void sendNotification(int type, String text)
Mediante esta función el dispositivo mostrara una notificación.
* int type: 1 para llamadas, 2 para mensajes.
* String text: Texto que se mostrará.

#### void setCameraControl(boolean flag)
Mediante esta función se muestra o oculta el controlador de la cámara en el dispositivo.
* boolean flag: True muestra el controlador de la cámara, false lo oculta.

#### void syncHeartRateData(boolean sync)
Inicia la sincronización del cardio con el dispositivo.
* boolean sync: True activar sincronización, false desactivar sincronización.


## CallbackHandler
Esta clase sirve para gestionar las respuestas del dispositivo.

### Posibles respuestas del dispositivo.

#### onWristBandFindNewAgreement(BluetoothDevice device)
Este método es invocado cuando al escanear se encuentra un nuevo dispositivo.
* BluetoothDevice device: Dispositivo encontrado.

#### connectStatue(boolean isConnect)
Este método se invoca cuando cambia el estado de conexión con el dispositivo.
* boolean isConnect: true conectado, false desconectado.

#### onDeviceInfoReceived(DeviceInfo deviceInfo)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getDeviceInfo()`.
* DeviceInfo deviceInfo: Objeto con la información del dispositivo.
  * String model: Modelo.
  * int oadmode
  * String swversion: Versión del firmware.
  * long intSwversion: Versión del firmware.
  * String bleAddr: Direccion Bluetooth

#### onPowerInfoReceived(PowerInfo powerInfo)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getPower()`.
* PowerInfo powerInfo: Objeto con la información de la batería.
  * int batteryPercentage: Porcentaje de la batería.

#### onSedentaryRemindersReceived(ArrayList\<SedentaryReminder> sedentaryReminders)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getSedentaryReminder()`.
* ArrayList\<SedentaryReminder> sedentaryReminders: Listado de las alarmas sedentarias establecidas en el dispositivo.
  * Integer index: Índice de la alarma sedentaria. 
  * Integer week: Días de la semana en los que sonará y si se va a repetir. Week es un tipo de dato que necesita de una [explicación más exhaustiva](#week).
  * Integer startHour: Hora de inicio.
  * Integer endHour: Hora de fin.
  * long duration: Cantidad de bloques de 5 minutos. Ej 1 = 5 minutos, 2 = 10 minutos.
  * Integer goal: Objetivo

#### onDeviceOptionsReceived(DeviceOptions deviceOptions)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getDeciceOptions()`.
* DeviceOptions deviceOptions: Objeto con la información de las opciones del dispositivo.
  * boolean light: Estado de la luz LED, true activo, false inactivo.
  * boolean gesture: Estado del control de gestos, true activo, false inactivo.
  * boolean unitType: True unidad de medida en inglés, false unidad de medida en Chino.
  * boolean time: True día 12h, false día 24h.
  * boolean sleep: True modo sueño automático, false modo sueño manual.
  * boolean adv: Estado de aviso al conectar, true activo, false inactivo.
  * int backlightStartTime: Hora de inicio de la luz de atrás.
  * int backlightEndTime: Hora de fin de la luz de atrás.
  * boolean color: Color de fondo, false negro, true blanco.
  * boolean language: True chino, false inglés.
  * boolean disconnect: Disconnect tip true on false off.

#### onKeyModelReceived(KeyModel keyModel)
Este método es invocado cuando se pulsa sobre la pantalla a la hora de tomar una foto.
* KeyModel keyModel: Objeto con la información del tipo de pulsación realizada en la pantalla del dispositivo.
  * int keyCode: 1 pulsación corta, 7 pulsación larga.

#### onHeartRateDetailReceived(HeartRateDetail heartRateDetail)
Este método es invocado cuando el dispositivo envía un dato de cardio, estos datos de cardio pueden ser enviados al activar la sincronización mediante el comando `syncHeartRateData(boolean sync)` o al completar una hora, es decir a las 13:00 mandará el resumen de las 12.
* HeartRateDetail heartRateDetail: Resumen horario con 60 detalles correspondientes a cada minuto de una hora.
  * Integer index: Índice de la actividad.
  * LinkedHashMap\<DateUtil, Integer> details: Lista con DateUtil fecha y Integer Pulsaciones por minuto.
* Observaciones:
  * Es posible recibir el resumen horario de la hora actual, en este caso el valor de las pulsaciones por minuto de los minutos que aún no se han producido será 255.

#### onSleepDataReceived(SleepData sleepData)
Este método es invocado cuando el dispositivo envía un dato de sueño, estos datos de sueño pueden ser enviados al activar la sincronización mediante el comando `syncActivityData(boolean sync)`, al completar una actividad de sueño o al realizar una nueva conexión estando la sincronización activa.
* SleepData sleepData: Objeto con la información de una actividad de sueño.
  * Integer index: Índice de la actividad.
  * Integer sleepType: [Tipo de sueño](#tipo-de-sueño).
  * DateUtil startDateTime: Fecha de inicio de actividad.
  * DateUtil endDateTime: Fecha de fin de actividad.
  * Integer duration: Duración de la actividad en minutos.

#### onSportDataReceived(SportData sportData)
Este método es invocado cuando el dispositivo envía un dato de deporte, estos datos de deporte pueden ser enviados al activar la sincronización mediante el comando `syncActivityData(boolean sync)`, al completar una actividad de deporte o al realizar una nueva conexión estando la sincronización activa.
* SportData sportData: Objeto con la información de una actividad de deporte.
  * Integer index: Índice de la actividad.
  * Integer sportType: [Deporte](#deportes).
  * DateUtil startDateTime: Fecha de inicio de actividad.
  * DateUtil endDateTime: Fecha de fin de actividad.
  * Integer duration: Duración de la actividad en minutos.
  * Double calorie: Calorías quemadas.
  * Integer steps: Pasos realizados.
  * Double distance: Distancia recorrida.
  * Integer count: Número de repeticiones.
* Observaciones:
  * Todos los deportes tienen startDateTime, endDateTime, duration y calorie.
  * Si el deporte es 1 tendrá información de steps y distance.
  * Si el deporte es de 2 a 6 tendrá información de count.

#### onCurrentDataReceived(CurrentData currentData)
Este método es invocado cuando el dispositivo envía un dato de actividad diaria, estos datos pueden ser enviados al activar la sincronización mediante el comando `syncCurrentData(boolean sync)` o al realizar una nueva conexión estando la sincronización activa.
* CurrentData currentData: Objeto con el resumen de la actividad diaria de un deporte.
  * Integer sportType: [Tipo de sueño](#tipo-de-sueño).
  * Integer steps: Pasos realizados.
  * Double distance: Distancia recorrida.
  * Double calories: Calorías quemadas.
  * Integer count: Número de repeticiones.
  * DateUtil date: Fecha.

#### onSupportedSportsReceived(SupportedSports supportedSports)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getSupportedSports()`.
* SupportedSports supportedSports: Objecto con la información de los deportes soportados por el dispositivo.
  * int maxCant: Cantidad máxima de deportes asignables.
  * int[] ids: Array con los id de los deportes asignables, [Deportes](#deportes).
* Observaciones:
  * Es posible que aún no saliendo en el listado se le puedan asignar otros deportes.

#### onUserInfoReceived(UserInfo userInfo)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getUserInfo()`.
* UserInfo userInfo: Objeto con la información del usuario en el dispositivo.
  * int height: Altura.
  * int weight: Peso.
  * boolean gender: true hombre, false mujer.
  * int age: Edad.
  * int goal: Objetivo en pasos.

#### onAlarmClockReceived(AlarmClock alarmClock)
Este método es invocado cuando se recibe la respuesta del comando `WristBandDevice.getAlarmClock(...)`.
* AlarmClock alarmClock: Objeto con la información de una alarma.
  * int id: Id de la alarma.
  * boolean smart: SMART???.
  * int week: Días de la semana en los que sonará y si se va a repetir. Week es un tipo de dato que necesita de una [explicación más exhaustiva](#week).
  * int hour: Hora.
  * int min: Minuto.

## Datos

### Week
Colección de 8 bits en un byte.
* week[7] repetir, 1 sí 0 no.
* week[6] Lunes, 1 sí 0 no.
* week[5] Martes, 1 sí 0 no.
* week[4] Miércoles, 1 sí 0 no.
* week[3] Jueves, 1 sí 0 no.
* week[2] Viernes, 1 sí 0 no.
* week[1] Sábado, 1 sí 0 no.
* week[0] Domingo, 1 sí 0 no.

Ejemplos: 
* Miércoles y repetir 144, (miércoles = 16) + (repetir = 128) = 144
* De lunes a viernes sin repetir 124. (lunes = 64) + (martes = 32) + (miércoles = 16) + (jueves = 8) + (viernes = 4) = 124

### Deportes
Listado de deportes:
* 1: walk
* 2: sit-up
* 3: push-up
* 4: rope-skipping
* 5: mountainneering
* 6: pull-up
* 128: badminton
* 129: basketball
* 130: football
* 131: swim
* 132: volleyball
* 133: table-tennis
* 134: bowling
* 135: tennis
* 136: cycling
* 137: ski
* 138: skate
* 139: rock-climbing
* 140: gym
* 141: dance
* 142: tablet-support
* 143: gym-exercise
* 144: yoga
* 145: shuttlecock

### Tipo de sueño
Listado de los tipos de sueño.
* 1: Enter sleep
* 2: Wakeup
* 3: Deep sleep
* 4: Shallow sleep
* 5: No wear






