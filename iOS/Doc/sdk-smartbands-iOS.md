# Documentación sdk-smartbands-ios

Este SDK contempla métodos para conexión, configuración y obtención de datos de los dispositivos Fit Pro 9614N, Fit Pulse 9615N y Smartee Training 9616N para la plataforma iOS.

## Clase TrainingManager
**TrainingManager** es la clase que centra las llamadas de búsqueda de dispositivos (scanDevice, stopScan, getDevices), conexión (connectDevice), estado de la conexión (currentState, isConnected, isBinded), desconexión (unConnectDevice, debind), llamadas para obtención de datos (getDeviceInfo, getSupportSportsList, getCurrentSportData, getHRDataOfHours, sportDataSwitchOn), devolución de los datos a través de notificaciones (CurrentWholeDaySportDataNotification, WholeDaySportDataNotification, SportDataDetailNotification, SleepDataNotification, HeartRateDataHoursNotification, SupportSportsListNotification, TakePictureNotify, SearchPhoneNotify, updateDeviceInfo, updateBattery), llamada de configuración de los deportes activos en los dispositivos (setSportTarget) y llamada de reinicio del dispositivo (deviceReset). 

**TrainingManager** implementa los protcolos definidos en la clase BLELib3 que es la clase que implementa la comunicación directa con los dispositivos:

### Protocolos
* @protocol IWBLEDiscoverDelegate
    * `- (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice;`

* @protocol IWBLEConnectDelegate
    * `- (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device;`
    * `- (void)IWBLEDidFailToConnectDevice:(IwownBlePeripheral *)device;`andError:(NSError *)error;
    * `- (void)deviceDidDisConnectedWithSystem:(NSString *)deviceName;`

* @protocol BLELib3Delegate
    * `- (void)setBLEParameterAfterConnect;`
    * `- (void)updateDeviceInfo:(DeviceInfo*)deviceInfo;`
    * `- (void)updateBattery:(DeviceInfo *)deviceInfo;`

    Los métodos abajo de actualización (update) son llamados por el SDK cuando hay nuevos datos enviados por el dispositivo, la aplicación debe estar preparada para recibirlos y guardarlos, si procede. El dispositivo no vuelve a enviar estos datos posteriormente, solamente datos nuevos.
    
    * `- (void)updateSleepData:(NSDictionary *)dict;`
    * `- (void)updateSportData:(NSDictionary *)dict;`
    * `- (void)updateWholeDaySportData:(NSDictionary *)dict;`
    * `- (void)updateHeartRateData_hours:(NSDictionary *)dict;`
    * `- (void)updateCurrentWholeDaySportData:(NSDictionary *)dict;`
    * `- (void)notifySupportSportsList:(NSDictionary *)ssList;`
    * `- (void)notifyToSearchPhone;`
    * `- (void)notifyToTakePicture; `

    * `- (void)responseOfScheduleSetting:(BOOL)success;`  
    * `- (void)responseOfScheduleGetting:(BOOL)exist;` 
    * `- (void)responseOfScheduleInfoGetting:(NSDictionary *)dict;` 

    Los métodos abajo están definidos en el protocolo BLELib3 pero no tinen el correspondiente get.

    * `- (void)responseOfGetTime:(NSDate *)date;`
    * `- (void)responseOfGetClock:(IwownClock *)clock;`
    * `- (void)responseOfGetSedentary:(IwownSedentary *)sedentary;`
    * `- (void)responseOfGetHWOption:(IwownHWOption *)hwOption;`
    * `- (void)responseOfGetSprotTarget:(IwownSportTarget *)spModel;`

### Proceso de búsqueda y conexión:

* apuntarse a las notificaciones 'DeviceFoundNotification': se envían a cada dispositivo encontrado
* llamar a [TrainingManager sharedInstance] `scanDevice`: inicia el proceso de escaneo,
* esperar a las notificaciones 'DeviceFoundNotification', la notificación trae en el parámetro 'userInfo' un diccionario:
    - @"deviceId": iwDevice.uuidString
    - @"iwDevice": iwDevice
Dónde iwDevice es un objeto de la clase 'IwownBlePeripheral' que representa el dispositivo Bluetooth encontrado (ver IwownBlePeripheral.h para conocer sus propiedades )
* llamar a [TrainingManager sharedInstance] `getDevices`: devuelve un array con todos los dispositivos encontrados hasta el momento, es un array con objetos de la clase 'IwownBlePeripheral'.
* llamar a [TrainingManager sharedInstance] `connectDevice` pasando como parámetro un objeto del tipo 'IwownBlePeripheral'
* esperar por la notificación de 'updateDeviceInfo' y 'updateBattery', ambas devuelven, en el parámetro object de la notificación, un objeto del tipo DeviceInfo (ver archivo DeviceInfo.h para conocer sus propiedades)
* para chequear si el dispositivo sigue conectado, hay que llamar a [TrainingManager sharedInstance] `isConnected`

Cuando el dispositivo se conecta, el sdk automaticamente hace una sincronización con el dispositivo solicitando información de actividad, sueño y deporte.  

### Proceso de recepción de datos:

A través del protocolo BLELib3Delegate, cuyos métodos ya están implementados en la clase **TrainingManager**, se reciben los datos enviados por el dispositivo, bien sea respondendo a la sincronización automática o debido a una solicitud de la  aplicación.

**TrainingManager** envía las siguientes notificaciones al recibir datos del dispositivo:

* CurrentWholeDaySportDataNotification: totales del día de hoy. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - steps: \< pasos >
    - calorie: \< calorias >
    - distance: \< distancia >
    - raw_data: \< diccionario: datos del sdk original >
        + calorie = \<calorias>
        + count = \< entero devuelto por algunos deportes para indicar cantidad de actividad >
        + "data_from" = \< IwownBlePeripheral.deviceName >
        + day = \< día >
        + distance = \<distancia>
        + month = \< mes >
        + "sport_type" = \< número identificador del [deporte](#deportes) >
        + steps = \<pasos>
        + week = \< semana >;
        + year = \< año >;

Obs. los datos de fecha day, week, month e year en esta notificación no deben ser considerados, la fecha para **current** corresponde a hoy.

* WholeDaySportDataNotification: totales de un día anterior a hoy. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - date:\<yyyymmdd>
    - sport_type:\< número identificador del [deporte](#deportes) >
    - steps: \<pasos>
    - calorie: \<calorias>
    - distance: \<distancia>
    - raw_data: \<diccionario: datos del sdk original >
        + calorie = \<calorias>
        + count = \< entero devuelto por algunos deportes para indicar cantidad de actividad >
        + "data_from" = \< IwownBlePeripheral.deviceName >
        + day = \< día >
        + distance = \<distancia>
        + month = \< mes >
        + "sport_type" = \< número identificador del [deporte](#deportes) >
        + steps = \<pasos>
        + week = \< semana >;
        + year = \< año >;

Obs. para esta notificación, los datos de fecha day, month e year deben ser considerados.

* SportDataDetailNotification: detalle de un deporte, puede ser andar (código 0x01) u otro que haya sido activado en el dispositivo. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - start_time:\< yyyy-mm-dd hh:mm:00 - fecha inicio de la actividad >
    - end_time:\< yyyy-mm-dd hh:mm:00 - fecha fin de la actividad >
    - sport_type:\< número identificador del [deporte](#deportes) >
    - steps: \<pasos>
    - calorie: \<calorias>
    - distance: \<distancia>
    - raw_data: \<diccionario: datos del sdk original >
        + calorie = \<calorias>
        + "data_from" = \< IwownBlePeripheral.deviceName >
        + day = \< día >
        + detail_data: \< diccionario con detalles del deporte, dependiendo del deporte puede devolver diferentes parámetros (activity, count, distance) >
        + end_time = \< número total de minutos del día correspondiente al momento fin de la actividad >
        + month = \< mes >
        + "sport_type" = \< número identificador del [deporte](#deportes) >
        + start_time = \< número total de minutos del día correspondiente al momento inicio de la actividad >
        + week = \< semana >;
        + year = \< año >;
        
Obs. para esta notificación, los datos de fecha day, month e year deben ser considerados.

* SleepDataNotification: detalle de un período de sueño. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - start_time:\< yyyy-mm-dd hh:mm:00 - fecha inicio del periodo de sueño >
    - end_time:\< yyyy-mm-dd hh:mm:00 - fecha fin del periodo de sueño >
    - sleep_type:\< número identificador de la calidad del [sueño](#sleep-type) >
    - raw_data: \<diccionario: datos del sdk original >
        + "data_from" = \< IwownBlePeripheral.deviceName >
        + day = \< día >
        + end_time = \< número total de minutos del día correspondiente al momento fin de la actividad >
        + month = \< mes >
        + "sleep_type" = \< número identificador de la calidad del [sueño](#sleep-type)) >
        + start_time = \< número total de minutos del día correspondiente al momento inicio de la actividad >
        + week = \< semana >;
        + year = \< año >;
        
Obs. para esta notificación, los datos de fecha day, month e year deben ser considerados. El sueño puede venir partido en muchos periodos.

* HeartRateDataHoursNotification: detalle del cardio en periodos de una hora. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - date:\< yyyy-mm-dd hh:00 - fecha/hora del periodo de cardio >
    - rate:\< array con 60 registros del cardio correspondiente a los 60 minutos de la hora >
    - raw_data: \<diccionario: datos del sdk original >
        + day = \< día >
        + "detail_data" = \< array con 60 registros del cardio correspondiente a los 60 minutos de la hora >
        + hour = \< hora al que corresponde los datos de cardio >
        + month = \< mes >
        + year = \< año >

Obs. Los dispositivos solo devuelven datos de cardio de las horas completas. Son 60 registros correspondientes a los 60 minutos de la hora empezando por el minuto 0 hasta el 59. El valor '255' deben ser descartado, en el minuto correspondiente no hubo dato válido de cardio.

**Importante**: para recibir los datos de cardio hay que activar la sincronización automática de cardio, para activarla, una vez que se conecte al dispositivo hay que llamar a [TrainingManager sharedInstance] `getHRDataOfHours`, a partir de ese momento se recibiran notificaciones de cardio a cada hora completa.

* SupportSportsListNotification: listado de deportes que soporta el dispositivo. Esta notificación se genera en respuesta al comando [TrainingManager sharedInstance] `getSupportSportsList`, y devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - SPORT_NAME: \< array con los nombres de los deportes que soporta el dispositivo >
    - SPORT_NUMBER: \< array con los códigos numéricos de los [deporte](#deportes) >
    - raw_data: \<diccionario: datos del sdk original >
        + LENGTH: \< número máximo de deportes que se poden activar en el dispositivo >
        + LIST: \< array con los códigos numéricos de los [deporte](#deportes) >
        + NAME: \< array con los nombres de los deportes soportados por el dispositivo, están en chino >
        + UNIT: \< array correspondiente a las unidades de medida de cada deporte >

Obs. SPORT_NAME y SPORT_NUMBER vienen ordenados de forma que la posición 0 en ambos corresponden al código del deporte y su respectivo nombre.

* TakePictureNotify: se recibe al pínhcar el botón de sacar fotos del dispositivo. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - type: TakePictureNotify

* SearchPhoneNotify: se recibe al pínchar el icono de búsqueda del móvil en el dispositivo. Esta notificación devuelve en el parámetro userInfo un diccionario con la siguiente información:
    - type: SearchPhoneNotify


**IMPORTANTE**: los datos recibidos a través de las notificaciones:

* WholeDaySportDataNotification
* SportDataDetailNotification
* SleepDataNotification
* HeartRateDataHoursNotification

deben ser almacenados en el momento en que se recibe la notificación, si se desea tener acceso a los mismo posteriormente, porque el dispositivo no los vuelve a enviar.

### Llamadas de obtención de datos del dispositivo:

Las siguientes llamadas de métodos públicos de [TrainingManager sharedInstance] sirven para obtener datos del dispositivo:

* `(void)getDeviceInfo`: información del dispositivo conectado. Devuelve la respuesta a través de la notificación:
    - updateDeviceInfo: notificación con la información del dispositivo, esta notificación devuelve en el parametro 'object' un objeto de la clase DeviceInfo (ver más detalles en el archivo DeviceInfo.h)
    - updateBattery: notificación con la información del nivel de bateria del dispositivo, esta notificación también devuelve en el parametro 'object' un objeto de la clase DeviceInfo.

* `(void)getSupportSportsList`: Obtención de los deportes soportados por el dispositivo. No siempre corresponde lo que devuelve el dispositivo con lo que se le puede activar. Devuelve la respuesta a través de la notificación:
    - SupportSportsListNotification: ver explicación arriba.

* `(void)getCurrentSportData`: obtención de los datos de actividad, sleep y deporte del día de hoy. Devuelve la respuesta a través de las notificaciones:
    - CurrentWholeDaySportDataNotification

* `(void)sportDataSwichOn:(BOOL)on`: activa la sincronización automática de datos (actividad/deportes) del dispositivo, si 'on' es YES, cada vez que el dispositivo termina un deporte envía automaticamente los datos del mismo a la aplicación, si 'on' es NO, no envía los datos hasta que se vuelva a llamar este método con 'on' igual a YES. Devuelve la respuesta a través de las notificaciones: 
    - CurrentWholeDaySportDataNotification
    - WholeDaySportDataNotification
    - SportDataDetailNotification
    - SleepDataNotification

* `(void)getHRDataOfHours`: activa la sincronización automática de los datos de cardio. Estos datos son devueltos al cambio de cada hora, siempre devolviendo los datos de la hora anterior que acaba de terminar. Devuelve la respuesta a través de la notificación:
    - HeartRateDataHoursNotification

### Llamadas de configuración del dispositivo:

* `(void)setSportTarget:(NSMutableArray *)targetArray`: activa los deportes en el dispositivo. Recibe como parámetro un array de diccionarios, cada diccionario corresponde a un deporte que se quiere activar, este diccionario tiene el siguiente formato: 
    - sportType: \<codigo del deporte que se quiere activar >
    - target: \< el objetivo, cantidad de calorias >

Se puede activar como máximo 5 deportes, sendo uno de ellos obligatoriamente el de 'caminar' (código 0x01 - WALKING).

Obs. se activan los mismos deportes para los 7 días de la semana.

### Llamada de reinicio del dispositivo

* `(void)deviceReset`: reinicia el dispositivo 

## Clase BLELib3

### Llamadas de configuración de funcionalidades

Los siguientes métodos están implementados en la clase BLELib3 y deben ser llamados a través de la instancia compartida de esta clase [BLELib3 shareInstance].

#### Alarma de sedentario:

Se permite configurar un unico alarma de sedentario:
* `(void)setAlertMotionReminder:(IwownSedentary *)sedentaryModel`: hay que pasarle un parámetro del tipo IwownSedentary (ver archivo IwownModel.h para más detalles), este parámetro tendría los siguientes datos:
    - IwownSedentary *sedentaryModel
        + [sedentaryModel setStartHour:\<int>]
        + [sedentaryModel setStartHour:\<int>]
        + [sedentaryModel setEndHour:\<int>]
        + [sedentaryModel setWeekRepeat:\<int>]: byte más bajo con la siguiente configuración de bits:
            * b7: repeat flag, si está activo repite semanalmente la alarma el/los día/s que estén configurados en los siguientes bits
            * b6: lunes
            * b5: martes
            * b4: miércoles
            * b3: jueve
            * b2: viernes
            * b1: sábado
            * b0: domingo
        + [sedentaryModel setSwitchStatus:\<booleano>]: true para activar y false para desactivar 

#### Información personal

Se configura la información personal a través del metodo:
* `(void)setPersonalInfo:(IwownPersonal *)personalModel`: hay que pasarle un parámetro del tipo 'IwownPersonal' (ver archivo IwownModel.h para más detalles), este parámetro tendría los siguientes datos:
    - IwownPersonal *iwPersonal
        + [iwPersonal setGender: \<0: man, 1:woman ]
        + [iwPersonal setHeight: \<int>]
        + [iwPersonal setWeight: \<int>]
        + [iwPersonal setTarget: \<int>]
        + [iwPersonal setAge:\<int>]

#### Alarma

Se configuran alarmas través del metodo:
* `(void)setScheduleClock:(IwownClock *)clockModel`: hay que pasarle un parámetro del tipo 'IwownClock' (ver archivo IwownModel.h para más detalles), este parámetro tendría los siguientes datos:
    - IwownClock *clockModel
        + [clockModel setClockId:\<int>]: index: índice identificador de la alarma. Su valor varia de 0 a 7, permitiendo configurar hasta 8 alarmas
        + [clockModel setSwitchStatus:\<status>]: Booleano: YES para que suene la alarma
        + [clockModel setViable:\<viable>]: Booleano: YES para que suene la alarma
        Obs. Ambos 'SwitchStatus' y 'Viable' deben ser 'YES' para que la alarma suene
        + [clockModel setClockHour:\<int>]
        + [clockModel setClockMinute:]
        + [clockModel setWeekRepeat:\<int>]: int: byte más bajo con la siguiente configuración de bits:
            * b7: repeat flag, si está activo repite semanalmente la alarma el/los día/s que estén configurados en los siguientes bits
            * b6: lunes
            * b5: martes
            * b4: miércoles
            * b3: jueve
            * b2: viernes
            * b1: sábado
            * b0: domingo

Observaciones:
* activar: es obligatorio que las propiedades SwitchStatus y Viable estén a true y que se active al menos un flag de día de semana en la propiedad WeekRepeat, el flag b7 de repetición puede estar a 0
* desactivar: poner WeekRepeat a 0, o SwitchStatus o Viable a false.
* repeticiones: si el flag de repetición está a 1, la alarma repite semanalmente, si está a off, es una alarma puntual

#### Schedule

Se configuran calendarios a través de los métodos: 
* `(void)writeSchedule:(IwownSchedule *)sModel`: crea un nuevo calendario, hay que pasarle un parámetro del tipo 'IwownSchedule' (ver archivo IwownModel.h para más detalles), este parámetro tendría los siguientes datos:
    - IwownSchedule *scheduleModel
        + scheduleModel.year = \<int>
        + scheduleModel.month = \<int>
        + scheduleModel.day = \<int>
        + scheduleModel.hour = \<int>
        + scheduleModel.minute = \<int>
        + scheduleModel.title = \<string max 20>
        + scheduleModel.subTitle = \<string max 33>

Se pueden crear hasta 4 schedule al día y no pueden haber dos en la misma fecha/hora.
* `(void)closeSchedule:(IwownSchedule *)sModel`: borra el calendario correpondiente al parámetro sModel.
* `clearAllSchedule`: remove todos los calendarios configurados en el dispositivo

Los métodos anteriores (writeSchedule, closeSchedule, clearAllSchedule) siempre retornan respuesta con el método:
* `(void)responseOfScheduleSetting:(BOOL)success`: si la configuración ha sido con éxito retorna 1, si no 0

Los siguientes métodos para leer información de schedule del dispositivo siempre retornan respuesta con el método `(void)responseOfScheduleGetting:(BOOL)exist`:
* `(void)readScheduleInfo`: retorna siempre YES
* `(void)readSchedule:(IwownSchedule *)sModel`: retorna 0 si el schedule no existe y 1 si el schedule existe

#### Sacar fotos con cámara

Para activar el modo sacar foto, hay que llamar al método:
* `(void)setKeyNotify:(NSUInteger)keyNotify`: dónde el parámetro keyNotify puede tener los siguientes valores:
    - 1: activar
    - 0: desactivar

Al activar el modo sacar foto, el dispositivo muestra el botón de sacar fotos. Al pínchar el botón se recibe una notificación a través del método: 
* `(void)notifyToTakePicture`
Este mismo evento pude ser capturado a través de la notificación 'TakePictureNotify'.

#### Buscar móvil

Para buscar el móvil, al dar al icono de búsqueda en el dispositivo, se recibe una notificación a través del método:
* `(void)notifyToSearchPhone`
Este mismo evento pude ser capturado a través de la notificación 'SearchPhoneNotify'.

### Configuraciones del dispositivo

Es posible configurar algunas opciones del dispositivo a través del método: 
* `(void)setFirmWareOption:(IwownHWOption *)hwOptionModel`: el parámetro de la clase IwownHWOption dispone de las siguientes propiedades: 
    - unitType: \<int>
        + UnitTypeInternational = 0 (km、meter、kg)
        + UnitTypeEnglish (feet、inch、pound)
    -  timeFlag (int) :
        +  TimeFlag24Hour = 0
        +  TimeFlag12Hour
    - autoSleep (BOOL) : YES/NO: reconoce automaticamente el estado sleep
    - backlightStart (int) : hora inicio para que se incenda la luz nocturna
    - backlightEnd (int) : hora fin para que se incenda la luz nocturna
    - backColor (BOOL) : sólo para dispositivos modelos 9616
        + YES : white color background
        + NO : black color background
    - language (int) : idioma del dispositivo
        + braceletLanguageEnglish = 0
        + braceletLanguageSimpleChinese                
    - leSwitch (BOOL)
    - wristSwitch (BOOL)

#### Push de string

* `(void)pushStr:(NSString *)str`: permite enviar un texto al dispositivo que se visualiza imediatamente.

## APENDICE I

### DEPORTES
CÓDIGO DE LOS DEPORTES PARA LOS DISPOSITIVOS TRAINING
* 1   : 0x01 : walk
* 2   : 0x02 : situp
* 3   : 0x03 : push-up
* 4   : 0x04 : rope skipping
* 5   : 0x05 : climb
* 6   : 0x06 : pull-up
* 128 : 0x80 : badminton
* 129 : 0x81 : basketball
* 130 : 0x82 : football
* 131 : 0x83 : swim
* 132 : 0x84 : volleyball
* 133 : 0x85 : pingpong
* 134 : 0x86 : bowling
* 135 : 0x87 : tennis
* 136 : 0x88 : cycling
* 137 : 0x89 : ski
* 138 : 0x8a : skating
* 139 : 0x8b : rock climbing
* 140 : 0x8c : gym
* 141 : 0x8d : dance
* 142 : 0x8e : tablet support
* 143 : 0x8f : gym exercise
* 144 : 0x90 : yoga
* 145 : 0x91 : shuttlecock

### SLEEP TYPE
CÓDIGO SLEEP TYPE Y SIGNIFICADO

* 1: SleepTypeStartSleep
* 2: SleepTypeEndSleep
* 3: SleepTypeDeepSleep
* 4: SleepTypeLightSleep
* 5: SleepTypePlaced
* 6: SleepTypeWakeUp




