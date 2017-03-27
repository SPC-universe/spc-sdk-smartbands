# Documentación sdk-smartbands-ios

Este SDK contempla métodos para conexión, configuración y obtención de datos de los dispositivos Fit Pro 9614N, Fit Pulse 9615N y Smartee Training 9616N para la plataforma iOS.

## PROTOCOLOS
* @protocol IWBLEDiscoverDelegate
    * - (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice

* @protocol IWBLEConnectDelegate
    * - (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device;
    * - (void)IWBLEDidFailToConnectDevice:(IwownBlePeripheral *)device andError:(NSError *)error;
    * - (void)deviceDidDisConnectedWithSystem:(NSString *)deviceName;

* @protocol BLELib3Delegate
    * `- (void)setBLEParameterAfterConnect;`

    - (void)updateDeviceInfo:(DeviceInfo*)deviceInfo;
    - (void)updateBattery:(DeviceInfo *)deviceInfo;

    Los métodos abajo de actualización (update) son llamados por el SDK cuando hay nuevos datos enviados por el dispositivo, la aplicación debe estar preparada para recibir estos datos y guardarlos, si procede. El dispositivo no vuelve a enviar estos datos, solamente datos nuevos.
    
    - (void)updateSleepData:(NSDictionary *)dict;
    - (void)updateSportData:(NSDictionary *)dict;
    - (void)updateWholeDaySportData:(NSDictionary *)dict;
    - (void)updateHeartRateData_hours:(NSDictionary *)dict;
    - (void)updateCurrentWholeDaySportData:(NSDictionary *)dict;
    - (void)notifySupportSportsList:(NSDictionary *)ssList;
    - (void)notifyToSearchPhone;
    - (void)notifyToTakePicture; 

    Los métodos abajo existen pero 

    - (void)responseOfGetTime:(NSDate *)date;
    - (void)responseOfGetClock:(IwownClock *)clock;
    - (void)responseOfGetSedentary:(IwownSedentary *)sedentary;
    - (void)responseOfGetHWOption:(IwownHWOption *)hwOption;
    - (void)responseOfGetSprotTarget:(IwownSportTarget *)spModel;

    - (void)responseOfScheduleSetting:(BOOL)success;
    - (void)responseOfScheduleGetting:(BOOL)exist;
    - (void)responseOfScheduleInfoGetting:(NSDictionary *)dict;


## CLASE BLELib3
 
### LLAMADAS DE CONEXIÓN
* - (void)scanDevice;
* - (void)stopScan;
* - (void)connectDevice:(IwownBlePeripheral *)dev;
* - (void)unConnectDevice;
* - (void)reConnectDevice;
* - (NSArray *)retrieveConnectedPeripherals;
* - (void)debindFromSystem;

## LLAMADAS DE OBTENCIÓN DE DATOS DEL DISPOSITIVO:

    - (void)getDeviceInfo;
        Callback
            - (void)updateDeviceInfo:(DeviceInfo*)deviceInfo;



    - (void)getSupportSportsList; 
        Obtención de los deportes soportados por el dispositivo. No siempre corresponde lo que devuelve el dispositivo con lo que se le puede activar. 
        Método del protocolo 'BLELib3Delegate' que devuelve la respuesta:
            - (void)notifySupportSportsList:(NSDictionary *)ssList;
            Formato ssList:
                * LENGTH : numero maximo deporte que se puede activar. Son 5 y el primer (1) tiene que ser siempre WALKING
                * LIST : array con códigos numéricos identificativos de cada tipo de deporte ([Ver APENDICE I - referencia código numérico y deporte correspondiente](#CÓDIGO))
                * NAME : array con los correspondientes nombres de los deportes
                * UNIT : array con las correspondientes unidades de cada deporte


    - (void)getCurrentSportData;
        Callback



    - (void)sportDataSwichOn:(BOOL)on;
        Ejecuta las peticiones de los comandos 0x28 (sync datos deporte) , 0x29 (sync datos día) y 0x53 (sync HR por horas)

???- (void)getHRParam;
        Callback
            - (void)updateHeartRateData:(NSDictionary *)dict;

    - (void)getHRDataOfHours;
        Callback
            - (void)updateHeartRateData_hours:(NSDictionary *)dict;

    - (void)deviceReset;


## PROTOCOLO DE CONFIGURACIÓN Y OBTENCIÓN DE DATOS

@protocol BLELib3Delegate
    - (void)setBLEParameterAfterConnect;

"CALLBACKS DE DATOS DEL SDK"




## LLAMADAS DE CONFIGURACIÓN 

### ALARMA DE SEDENTARIO:
    Se permite configurar un unico alarma de sedentario con los siguientes parametros:
    IwownSedentary *sedentaryModel
                    [sedentaryModel setStartHour:<int>];
                    [sedentaryModel setEndHour:<int>];
                    [sedentaryModel setWeekRepeat:<int>]; // int: byte más bajo con la siguiente configuración de bits
                                                    b7: repeat flag, si está activo repite semanalmente la alarma el/los día/s que estén configurados en los siguientes bits
                                                    b6: lunes
                                                    b5: martes
                                                    b4: miércoles
                                                    b3: jueves
                                                    b2: viernes
                                                    b1: sábado
                                                    b0: domingo
                    [sedentaryModel setSwitchStatus:<booleano>]; // true para activar y false para desactivar
    El método para configurar el alarma de sedentario es:
        - (void)setAlertMotionReminder:(IwownSedentary *)sedentaryModel;


### PERSONAL INFORMATION
    Para configurar la información personal, hay que crear un objeto del tipo 'IwownPersonal' y configurarle llamando los siguientes métodos:
            IwownPersonal *iwPersonal 
                                [iwPersonal setGender: <0: man, 1:woman ];
                                [iwPersonal setHeight: <int>];
                                [iwPersonal setWeight: <int>];
                                [iwPersonal setTarget: <int>];
                                [iwPersonal setAge:<int>];
     Y enviar el comando al dispositivo:      
          - (void)setPersonalInfo:(IwownPersonal *)personalModel;

### ALARMA
    Para configurar alarmas, hay que crear un objeto del tipo 'IwownClock' y configurarle llamando los siguientes métodos:
    [clockModel setClockId:index];          // index: índice identificador de la alarma. Su valor varia de 0 a 7, permitiendo configurar hasta 8 alarmas
    [clockModel setSwitchStatus:status];    // Booleano: true para que suene la alarma
    [clockModel setViable:viable];          // Booleano: true para que suene la alarma
                                            // Ambos 'SwitchStatus' y 'Viable' deben estar a true para que la alarma suene
    [clockModel setClockHour:hour];         // int: hora de la alarma
    [clockModel setClockMinute:minute];     // int: minutos de la alarma
    [clockModel setWeekRepeat:repeat];      // int: byte más bajo con la siguiente configuración de bits
                                                    b7: repeat flag, si está activo repite semanalmente la alarma el/los día/s que estén configurados en los siguientes bits
                                                b6: lunes
                                                b5: martes
                                                b4: miércoles
                                                b3: jueves
                                                b2: viernes
                                                b1: sábado
                                                b0: domingo
    Y enviar el comando al dispositivo para activar/desactivar esta alarma:
        - (void)setScheduleClock:(IwownClock *)clockModel;

    Observaciones:
            - activar: es obligatorio que las propiedades SwitchStatus y Viable estén a true y que se active al menos un flag de día de semana en la propiedad WeekRepeat, el flag b7 de repetición puede estar a 0
            - desactivar: poner WeekRepeat a 0, o SwitchStatus o Viable a false.
            - repeticiones: si el flag de repetición está a 1, la alarma repite semanalmente, si está a off, es una alarma puntual


### CONFIGURACIONES DEL DISPOSITIVO
    Es posible configurar algunas opciones del dispositivo a través del método: 
        - (void)setFirmWareOption:(IwownHWOption *)hwOptionModel;

    El objeto de la clase IwownHWOption dispone de las siguientes propiedades:

???- leSwitch (BOOL)

???- wristSwitch (BOOL)

        - unitType (int) :  UnitTypeInternational = 0 (km、meter、kg)
                            UnitTypeEnglish (feet、inch、pound)

        - timeFlag (int) :  TimeFlag24Hour = 0
                            TimeFlag12Hour

        - autoSleep (BOOL) : YES/NO: reconoce automaticamente el estado sleep

        - backlightStart (int) : hora inicio para que se incenda la luz nocturna

        - backlightEnd (int) : hora fin para que se incenda la luz nocturna

        - backColor (BOOL) : sólo para dispositivos modelos 9616
                            YES : white color background
                            NO : black color background
        - language (int) : idioma del dispositivo
                    braceletLanguageEnglish = 0,
                    braceletLanguageSimpleChinese


### SET SPORT TARGET
    Este comando activa los deportes en el dispositivo, el deporte WALKING (número 1) es obligatorio y siempre debe ser activado, se permite como máximo 5 deportes activos al día siendo el primer el deporte WALKING (1).
        - (void)setSportTarget:(NSMutableArray *)targetArray;
            el parametro 'targetArray' es un array con 7 posiciones correspondientes a los 7 días de la semana empezando por el lunes.
            Cada elemento de este array es a su vez un array de dicionarios con un máximo de 5 posiciones (5 deportes al día siendo el 1 obligatorio)
            Cada dicionario debe contener dos clave-valor: 
                            @{  @"TARGET": <string con el valor del goal para este deporte>,
                            @"TYPE": <string con el código numérico del deporte que se quiere activar> };

???- (void)setSportTargetBy:(IwownSportTarget *)st;

???- (void)pushStr:(NSString *)str; 

### SCHEDULE
    Se puede crear hasta 4 schedule al día y no puede haber dos en la misma fecha/hora.
        - (void)writeSchedule:(IwownSchedule *)sModel; //write schedule
        
        - (void)clearAllSchedule; //clear schedule
        
        - (void)closeSchedule:(IwownSchedule *)sModel; //shut down schedule

        Parámetro del tipo IwownSchedule:
                IwownSchedule *scheduleModel = [[IwownSchedule alloc] init];
                
                scheduleModel.year = <int>;
                scheduleModel.month = <int>;
                scheduleModel.day = <int>;
                scheduleModel.hour = <int>;
                scheduleModel.minute = <int>;
                scheduleModel.title = <string max 20>;
                scheduleModel.subTitle = <string max 33>;

    Los métodos anteriores (writeSchedule, closeSchedule, clearAllSchedule) siempre retornan respuesta con el método:
        - (void)responseOfScheduleSetting:(BOOL)success;
        Si la configuración ha sido con éxito retorna 1, si no 0.
    
    Los siguientes métodos para leer información de schedule del dispositivo siempre retornan respuesta con el método:
        - (void)responseOfScheduleGetting:(BOOL)exist;

        - (void)readScheduleInfo; //get schedule information
            retorna a través del método responseOfScheduleGetting, y siempre retorna YES (1);

        - (void)readSchedule:(IwownSchedule *)sModel; //get specified schedule
            también retorna a través del método responseOfScheduleGetting, retorna 0 si el schedule no existe y 1 si el schedule existe

### CÁMARA Y BUSCAR DISPOSITIVO
    Para activar el modo sacar foto, hay que llamar al método:
        - (void)setKeyNotify:(NSUInteger)keyNotify; 
        keyNotify:  1 - activar
                    0 - desactivar

    Al activar, el dispositivo muestra el botón de sacar fotos. Al pínchar el botón se recibe una notificación a través del método: 
        - (void)notifyToTakePicture; 

    Para buscar el móvil, al dar al icono de búsqueda en el dispositivo, se recibe una notificación a través del método:
        - (void)notifyToSearchPhone;


## APENDICE I

### CÓDIGO DE LOS DEPORTES PARA LOS DISPOSITIVOS TRAINING

      1   : 0x01 : walk
      2   : 0x02 : situp
      3   : 0x03 : push-up
      4   : 0x04 : rope skipping
      5   : 0x05 : climb
      6   : 0x06 : pull-up
      128 : 0x80 : badminton
      129 : 0x81 : basketball
      130 : 0x82 : football
      131 : 0x83 : swim
      132 : 0x84 : volleyball
      133 : 0x85 : pingpong
      134 : 0x86 : bowling
      135 : 0x87 : tennis
      136 : 0x88 : cycling
      137 : 0x89 : ski
      138 : 0x8a : skating
      139 : 0x8b : rock climbing
      140 : 0x8c : gym
      141 : 0x8d : dance
      142 : 0x8e : tablet support
      143 : 0x8f : gym exercise
      144 : 0x90 : yoga
      145 : 0x91 : shuttlecock

### CÓDIGO SLEEP TYPE Y SIGNIFICADO
* 1: SleepTypeStartSleep
* 2: SleepTypeEndSleep
* 3: SleepTypeDeepSleep
* 4: SleepTypeLightSleep
* 5: SleepTypePlaced
* 6: SleepTypeWakeUp




