#import <AVFoundation/AVFoundation.h>
#import "TrainingManager.h"
#import "DeviceInfo.h"
#import "SportManager.h"

@interface TrainingManager ()

@property (strong, nonatomic) SportManager *sportManager;
@property (strong, nonatomic) NSDateFormatter *gmtYmdHms;

@end

@implementation TrainingManager
{
    NSMutableArray *_deviceArray;
    NSArray        *_alertArray;
    NSDictionary   *_motionDict;
    NSDictionary   *_infoDict;
    NSDictionary   *_hwoption;
}

@synthesize state = _state;

+ (TrainingManager *)sharedInstance
{
    static TrainingManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrainingManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [BLELib3 shareInstance].delegate = self;
        [BLELib3 shareInstance].connectDelegate = self;
        [BLELib3 shareInstance].discoverDelegate = self;
        _deviceArray = [[NSMutableArray alloc] initWithCapacity:0];
        _sportManager = [SportManager sharedInstance];
        
        _gmtYmdHms = [[NSDateFormatter alloc] init];
        _gmtYmdHms.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [_gmtYmdHms setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    }
    return self;
}

- (void)setState:(kBLEstate)state
{
    _state = state;
}

- (void)setAutoReconnect:(BOOL)isNeed andReconnectCheckTime:(NSTimeInterval)timeSec
{
    __block TrainingManager *__safe_self = self;
    
    dispatch_queue_t queue = dispatch_queue_create("auto-reconnect-queue", 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeSec *NSEC_PER_SEC, 0.1 *   timeSec *NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if ([__safe_self auto_reconnect_cancel] ) {
            dispatch_source_cancel(timer);
        }
        __safe_self.state = [__safe_self currentState];
        
        //        NSLog(@"_state :=================== %d",__safe_self.state);
        
        if (__safe_self.state == kBLEstateBindUnConnected) {
            [[BLELib3 shareInstance] reConnectDevice];
        }
    });
    dispatch_resume(timer);
}

#pragma mark device & state

- (void)scanDevice
{
    [_deviceArray removeAllObjects];
    [[BLELib3 shareInstance] scanDevice];
}

- (void)stopScan
{
    [[BLELib3 shareInstance] stopScan];
}

- (NSArray *)getDevices
{
    return _deviceArray;
}

- (void)connectDevice:(IwownBlePeripheral *)device
{
    [[BLELib3 shareInstance] connectDevice:device];
}

- (void)unConnectDevice
{
    [[BLELib3 shareInstance] unConnectDevice];
}

- (void)debind
{
    [[BLELib3 shareInstance] debindFromSystem];
}

- (kBLEstate)currentState
{
    return [BLELib3 shareInstance].state;
}

- (BOOL)isBinded
{
    if ([self currentState] == kBLEstateDisConnected) {
        return NO;
    }
    return YES;
}

- (BOOL)isConnected
{
    if ([self currentState] == kBLEstateDidConnected) {
        return YES;
    }
    return NO;
}

#pragma mark IWBLEDiscoverDelegate

- (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice
{
    [_deviceArray addObject:iwDevice];
    [self postDeviceFoundNotification:iwDevice];
}

- (void)postDeviceFoundNotification:(IwownBlePeripheral *)iwDevice
{
    NSLog(@"postDeviceFoundNotification: %@", iwDevice.uuidString);
    
    NSDictionary *postInfo = @{ @"deviceId": iwDevice.uuidString,
                                @"iwDevice": iwDevice };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceFoundNotification" object:self userInfo:postInfo];
}

#pragma mark IWBLEConnectDelegate

- (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device
{
    NSLog(@"IWBLEDidConnectDevice - device: %@ ",device);
    [[NSUserDefaults standardUserDefaults] setObject:device.deviceName forKey:@"BIND_DEVICE_NAME"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DEVICEDIDCONNECTED" object:device];
    
    if (self.currentState == CurrentBLEProtocol3_0) {
        [self systemIniternalSetting];
    }
}

- (void)systemIniternalSetting
{
}

- (void)IWBLEDidFailToConnectDevice:(IwownBlePeripheral *)device andError:(NSError *)error
{
    NSLog(@"IWBLEDidFailToConnectDevice - device: %@ - error: %@",device,error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidFailToConnect" object:device];
}

- (void)deviceDidDisConnectedWithSystem:(NSString *)deviceName
{
    NSLog(@"deviceDidDisConnectedWithSystem - deviceName: %@ ",deviceName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnected" object:deviceName];
}

#pragma BLELib3Delegate (updates for sport/sleep/heartRate)

- (void)setBLEParameterAfterConnect
{
}

- (void)updateDeviceInfo:(DeviceInfo *)deviceInfo
{
    NSLog(@"updateDeviceInfo: %@", deviceInfo);
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceInfo.bleAddr forKey:@"BIND_DEVICE_MACADRESS"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeviceInfo" object:deviceInfo];
}

- (void)updateBattery:(DeviceInfo *)deviceInfo
{
    NSLog(@"updateBattery: %ld", (long)deviceInfo.batLevel);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBattery" object:deviceInfo];
}

- (void)updateCurrentWholeDaySportData:(NSDictionary *)data
{
    NSLog(@"updateCurrentWholeDaySportData: %@", data);
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:data[@"steps"] forKey:@"steps"];
    [userInfo setObject:data[@"calorie"] forKey:@"calorie"];
    [userInfo setObject:data[@"distance"] forKey:@"distance"];
 
    [userInfo setObject:data forKey:@"raw_data"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentWholeDaySportDataNotification" object:self userInfo:userInfo];
}

- (void)updateWholeDaySportData:(NSDictionary *)data
{
    NSLog(@"updateWholeDaySportData: %@", data);
    
    NSString *yyyymmdd = [NSString stringWithFormat:@"%@-%@-%@", data[@"year"], data[@"month"], data[@"day"]];
    NSString *sport_type = self.sportManager.training[@([data[@"sport_type"] intValue])];
    
    if (sport_type) {
        NSDictionary *userInfo = @{@"date":yyyymmdd,
                                   @"sport_type":sport_type,
                                   @"steps": data[@"steps"],
                                   @"calorie": data[@"calorie"],
                                   @"distance": data[@"distance"],
                                   @"raw_data":data};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WholeDaySportDataNotification" object:self userInfo:userInfo];
    }
}

- (void)updateSportData:(NSDictionary *)data
{
    NSLog(@"updateSportData: %@", data);
    
    int startTime = [data[@"start_time"] intValue];
    int h = startTime / 60;
    int m = startTime % 60;
    NSString *startDateStr = [NSString stringWithFormat:@"%@-%@-%@ %d:%d:00", data[@"year"], data[@"month"], data[@"day"], h, m];
    
    int endTime = [data[@"end_time"] intValue];
    h = endTime / 60;
    m = endTime % 60;
    NSString *endDateStr = [NSString stringWithFormat:@"%@-%@-%@ %d:%d:00", data[@"year"], data[@"month"], data[@"day"], h, m];
    NSDate *endDate = [self.gmtYmdHms dateFromString:endDateStr];
    
    // Si 'startTime' es mayor que 'endTime' es porque la actividad termina el día siguiente, hay que añadir 1 día a 'endDate'
    if (startTime > endTime) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                       value:1
                                      toDate:endDate
                                     options:0];
    }
    
    endDateStr = [self.gmtYmdHms stringFromDate:endDate];
    
    int sport_type = [data[@"sport_type"] intValue];
    NSString *sportTypeName = self.sportManager.training[@(sport_type)];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    [userInfo setObject:sportTypeName forKey:@"sport_type"];
    [userInfo setObject:startDateStr forKey:@"start_time"];
    [userInfo setObject:endDateStr forKey:@"end_time"];
    [userInfo setObject:data[@"calorie"] forKey:@"calorie"];
    
    NSError *error;
    NSDictionary *detail = [NSJSONSerialization JSONObjectWithData:[data[@"detail_data"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (!error) {
        int count = 0, steps = 0, distance = 0;
        if (sport_type != 0x01) {
            count = [detail[@"count"] intValue];
            [userInfo setObject:@(count) forKey:@"count"];
        }
        
        distance = [detail[@"distance"] intValue];
        steps = [detail[@"steps"] intValue];
        
        [userInfo setObject:@(steps) forKey:@"steps"];
        [userInfo setObject:@(distance)  forKey:@"distance"];
        [userInfo setObject:data forKey:@"raw_data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SportDataDetailNotification" object:self userInfo:userInfo];
    }
}

- (void)updateSleepData:(NSDictionary *)data
{
    NSLog(@"updateSleepData: %@", data);
    
    int startTime = [data[@"start_time"] intValue];
    int h = startTime / 60;
    int m = startTime % 60;
    NSString *startDateStr = [NSString stringWithFormat:@"%@-%@-%@ %d:%d:00", data[@"year"], data[@"month"], data[@"day"], h, m];
    NSDate *startDate = [self.gmtYmdHms dateFromString:startDateStr];
    
    int endTime = [data[@"end_time"] intValue];
    h = endTime / 60;
    m = endTime % 60;
    NSString *endDateStr = [NSString stringWithFormat:@"%@-%@-%@ %d:%d:00", data[@"year"], data[@"month"], data[@"day"], h, m];
    NSDate *endDate = [self.gmtYmdHms dateFromString:endDateStr];
    
    int duration = [endDate timeIntervalSinceDate:startDate];
    
    if (startDate && endDate && duration >= 0) {
        NSString *sleepType = @"";
        int sleep_type = [data[@"sleep_type"] intValue];
        switch (sleep_type) {
            case 1: // SleepTypeStartSleep
                sleepType = @"SleepTypeStartSleep";
                break;
                
            case 2: // SleepTypeEndSleep
                sleepType = @"SleepTypeEndSleep";
                break;
                
            case 3: // SleepTypeDeepSleep
                sleepType = @"SleepTypeDeepSleep";
                break;
                
            case 4: // SleepTypeLightSleep
                sleepType = @"SleepTypeLightSleep";
                break;
                
            case 5: // SleepTypePlaced
                sleepType = @"SleepTypePlaced";
                break;
                
            case 6: // SleepTypeWakeUp
                sleepType = @"SleepTypeWakeUp";
                break;
        }
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        
        [userInfo setObject:startDateStr forKey:@"start_time"];
        [userInfo setObject:endDateStr forKey:@"end_time"];
        [userInfo setObject:sleepType forKey:@"sleep_type"];
        [userInfo setObject:data forKey:@"raw_data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SleepDataNotification" object:self userInfo:userInfo];
    }
}

- (void)updateHeartRateData_hours:(NSDictionary *)data
{
    NSLog(@"updateHeartRateData_hours: %@", data);
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:00", data[@"year"], data[@"month"], data[@"day"], data[@"hour"]];
    
    NSArray *details = data[@"detail_data"];
    
    if (details.count > 0) {
        [userInfo setObject:dateStr forKey:@"date"];
        [userInfo setObject:details forKey:@"rate"];
        [userInfo setObject:data forKey:@"raw_data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HeartRateDataHoursNotification" object:self userInfo:userInfo];
    }
}

- (void)notifySupportSportsList:(NSDictionary *)ssList
{
    NSLog(@"TrainingManager - notifySupportSportsList: %@",ssList);
    [[NSUserDefaults standardUserDefaults] setObject:ssList forKey:@"SPORTSLIST"];
    
    NSMutableDictionary *sportListDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *sportListNames = [[NSMutableArray alloc] init];
    
    NSArray *sportListNumbers = ssList[@"LIST"];
    
    NSString *key = @"";
    for (int i = 0; i < sportListNumbers.count; i++ ) {
        key = sportListNumbers[i];
        sportListNames[i] = [self.sportManager.training objectForKey:key];
    }
    
    [sportListDic setValue:sportListNumbers forKey:@"SPORT_NUMBER"];
    [sportListDic setValue:sportListNames forKey:@"SPORT_NAME"];
    NSString *rawData = [NSString stringWithFormat:@"%@",ssList];
    [sportListDic setValue:rawData forKey:@"raw_data"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SupportSportsListNotification" object:self userInfo:sportListDic];
}

- (void)notifyToTakePicture
{
    NSDictionary *dict = @{@"type":@"TakePictureNotify"};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"TakePictureNotify" object:nil userInfo:dict];
}

- (void)notifyToSearchPhone
{
    NSDictionary *dict = @{@"type":@"SearchPhoneNotify"};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SearchPhoneNotify" object:nil userInfo:dict];
}

#pragma Get/Set Device data

- (void)getDeviceInfo
{
    [[BLELib3 shareInstance] getDeviceInfo];
}

- (NSMutableDictionary *)getSupportSportsList
{
    NSMutableDictionary *dict  = [[NSUserDefaults standardUserDefaults] objectForKey:@"SPORTSLIST"];
    
    if (dict == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"LENGTH":@"01", @"LIST":@[@"步行"],@"UNIT":@[@"步"]}];
        return dict;
    }
    
    [[BLELib3 shareInstance] getSupportSportsList];
    
    return dict;
}

- (BOOL)getCurrentSportData
{
    if (![self isConnected]) {
        return NO;
    }
    [[BLELib3 shareInstance] getCurrentSportData];
    return YES;
}

- (void)getHRDataOfHours{
    if ([self isConnected]) {
        [[BLELib3 shareInstance] getHRDataOfHours];
    }
}

/**
 *  Active data synchronization for
 *      28: syncing sports record
 *      29: syncing daily record 0x29
 *  on: YES (active sync), NO (deactive sync)
 */
- (void)sportDataSwichOn:(BOOL)on
{
    if ([self isConnected]) {
        [[BLELib3 shareInstance] sportDataSwichOn:on];
    }
}

- (void)setSportTarget:(NSMutableArray *)targetArray
{
    NSMutableArray *sportsDay = [[NSMutableArray alloc] init];
    
    for (NSDictionary *sport in targetArray) {
        NSDictionary *sportTarget = @{ @"TARGET": sport[@"target"],
                                       @"TYPE": sport[@"sportType"] };
        [sportsDay addObject:sportTarget];
    }
    
    NSMutableArray *sportsDays = [NSMutableArray arrayWithArray:
                                  @[
                                    sportsDay,
                                    sportsDay,
                                    sportsDay,
                                    sportsDay,
                                    sportsDay,
                                    sportsDay,
                                    sportsDay
                                    ]];
    [[BLELib3 shareInstance] setSportTarget:sportsDays];
}

- (void)deviceReset
{
    [[BLELib3 shareInstance] deviceReset];
}

#pragma mark - BLE Action

- (BOOL)syscMPSend:(NSDictionary *)mspdict andRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)hardWareOptionSet
{
    NSDictionary *hwDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"HWOPTION"];
    if (hwDic == nil) {
        hwDic = @{@"HOURS": @YES,
                  @"UNIT": @YES,
                  @"SLEEP": @YES,
                  @"WRIST": @YES,
                  @"LED": @NO};
        [[NSUserDefaults standardUserDefaults]setObject:hwDic forKey:@"HWOPTION"];
    }
    return hwDic;
}

- (BOOL)setHWOption:(NSDictionary *)hwoption andRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary *)personalInfoSet
{
    NSMutableDictionary *infoDict =[[NSMutableDictionary alloc] initWithCapacity:0];
    
    return infoDict;
}

- (BOOL)setPersonalInfo:(NSDictionary *)infoDict andRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (NSMutableArray *)alertByIndexSet
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SCHEDULE_CLOCK"];
}

- (BOOL)setScheduleAlert:(NSArray *)alertArray andRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary *)motionReminderSet
{
    NSDictionary *mDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"MOTION_REMIND"];
    if (mDic == nil) {
        mDic = [NSMutableDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO],
                                                            [NSNumber numberWithInteger:0],
                                                            [NSNumber numberWithInteger:0],
                                                            [NSNumber numberWithInteger:255]]
                                                  forKeys:@[@"SWITCH",@"STARTTIME",@"ENDTIME",@"REPEAT"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:mDic forKey:@"MOTION_REMIND"];
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_motionDict];
    return  dict;
}

- (BOOL)setMotionRemender:(NSDictionary *)motionDict andRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)syscTimeandRWQueueUsed:(BOOL)useRWQueue
{
    if (![self isConnected]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)wechatSwitch
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSP_SWITCH"];
    BOOL wechat = [dict[@"wechat"] boolValue];
    return wechat;
}

- (BOOL)qqSwitch
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSP_SWITCH"];
    BOOL qq = [dict[@"qq"] boolValue];
    return qq;
}

#pragma - mark Responses

- (void)responseOfGetHWOption:(IwownHWOption *)hwOption
{
    NSLog(@"responseOfGetHWOption: %@", hwOption);
}

- (void)responseOfGetTime:(NSDate *)date
{
    NSLog(@"responseOfGetTime: %@", date);
}

- (void)responseOfGetClock:(IwownClock *)clock
{
    NSLog(@"responseOfGetClock: %@", clock);
}

- (void)responseOfGetSedentary:(IwownSedentary *)sedentary
{
    NSLog(@"responseOfGetSedentary: %@", sedentary);
}

- (void)responseOfGetSprotTarget:(IwownSportTarget *)spModel
{
    NSLog(@"responseOfGetSprotTarget: %@", spModel);
}

- (void)updateCurrentHeartRateData:(NSDictionary *)data
{
    NSLog(@"updateCurrentHeartRateData: %@", data);
}

- (void)responseOfScheduleSetting:(BOOL)success
{
    NSLog(@"responseOfScheduleSetting: %@", success ? @YES : @NO);
}

- (void)responseOfScheduleGetting:(BOOL)exist
{
    NSLog(@"responseOfScheduleGetting: %@", exist ? @YES : @NO);
}

- (void)responseOfScheduleInfoGetting:(NSDictionary *)data
{
    NSLog(@"responseOfScheduleInfoGetting: %@", data);
}

@end
