#import "DataManager.h"

@interface DataManager ()

@end

@implementation DataManager

+ (DataManager *)sharedInstance
{
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _gmtTz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        _gmtCalendar = [NSCalendar currentCalendar];
        [_gmtCalendar setTimeZone:_gmtTz];
        
        _Ymdhms = [[NSDateFormatter alloc] init];
        _Ymdhms.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
        _gmtYmdHms = [[NSDateFormatter alloc] init];
        _gmtYmdHms.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [_gmtYmdHms setTimeZone:_gmtTz];
        
        _gmt = [[NSDateFormatter alloc] init];
        _gmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        [_gmt setTimeZone:_gmtTz];
        
        _gmtYmd = [[NSDateFormatter alloc] init];
        _gmtYmd.dateFormat = @"yyyy-MM-dd";
        [_gmtYmd setTimeZone:_gmtTz];
        
        _gmtHS = [[NSDateFormatter alloc] init];
        _gmtHS.dateFormat = @"HH:mm";
        [_gmtHS setTimeZone:_gmtTz];
        
        _man = YES;
        _goal = @(5000);
        
        _trainingManager = [TrainingManager sharedInstance];
        
        [self setupNotifications];
    }
    return self;
}

- (void)setupNotifications
{
    
}

#pragma IwownManager

- (void)scanDevice
{
    [self.trainingManager scanDevice];
}

- (void)stopScan
{
    [self.trainingManager stopScan];
}

- (NSArray *)getDevices
{
    return [self.trainingManager getDevices];
}

- (void)connectDevice:(IwownBlePeripheral *)device
{
    [self.trainingManager connectDevice:device];
}

- (void)disconnectDevice
{
    [self.trainingManager unConnectDevice];
}

- (BOOL)isConnected
{
    return [self.trainingManager isConnected];
}

- (void)debind
{
    [self.trainingManager debind];
}

- (void)deviceReset
{
    [self.trainingManager deviceReset];
}

#pragma Training get Data

- (void)getDeviceInfo
{
    [self.trainingManager getDeviceInfo];
}

- (void)getSupportSportsList
{
    [self.trainingManager getSupportSportsList];
}

- (void)getCurrentSportData
{
    [self.trainingManager getCurrentSportData];
}

- (void)sportDataSwitchOn:(BOOL)on
{
    [self.trainingManager sportDataSwichOn:on];
}

- (void)getHRDataOfHours
{
    [self.trainingManager getHRDataOfHours];
}

#pragma Training set Data

- (void)setSportTarget:(NSMutableArray *)targetArray
{
    [self.trainingManager setSportTarget:targetArray];
}

#pragma Training response to Html format

- (NSString *)headertHtml
{
    return @"<html><style>\
    img {height: auto; max-width:20px; vertical-align:middle; float:left; border:0; margin-right:10px}\
    .side { display: inline;}\
    h4 { font-size: 14px; color: #469900; border-bottom: 2px solid #469904;}\
    table { width: 100%; border: none; font-size: 14px;}\
    col { width:40%;}\
    td { text-align: left;}\
    body { font-family: \"Helvetica Neue\",Helvetica,Arial,sans-serif; font-size: 14px; line-height: 20px; color: #555555; }\
    a { text-decoration:none; background-color: none;}\
    span {color:#469900;font-weight:bold}\
    </style><body>";
    
}

- (NSString *)endHTml
{
    return @"</body></html>";
}

- (NSString *)formatearTitulo:(NSString *)titulo
{
    NSMutableString *htmlCode = [[NSMutableString alloc] initWithFormat:@"<h4>%@</h4>",titulo];
    return htmlCode;
}

- (NSString *)addDeviceInfoToHtml:(DeviceInfo *)deviceInfo
{
    NSMutableString *deviceInfoHtml = [[NSMutableString alloc] init];
    [deviceInfoHtml appendString:[self formatearTitulo:@"DeviceInfo"]];
    NSString *deviceInfoString = [NSString stringWithFormat:@"model: %@<br> version: %@<br> versionValue: %ld<br> oadMode: %ld<br> batteryLevel: %ld<br> seriesNo: %@<br> bleAddr: %@<br> customNo: %lu, hrVersion: %@<br> hrversionValue: %ld",deviceInfo.model,deviceInfo.version,deviceInfo.versionValue,deviceInfo.oadMode,deviceInfo.batLevel,deviceInfo.seriesNo,deviceInfo.bleAddr,deviceInfo.customNo,deviceInfo.hrVersion,deviceInfo.hrVersionValue];
    [deviceInfoHtml appendString:deviceInfoString];
    [deviceInfoHtml appendString:@"<br>"];
    return deviceInfoHtml;
}

- (NSString *)addUpdateBatteryToHtml:(DeviceInfo *)deviceInfo
{
    NSMutableString *deviceInfoHtml = [[NSMutableString alloc] init];
    [deviceInfoHtml appendString:[self formatearTitulo:@"UpdateBattery"]];
    NSString *updateBatteryString = [NSString stringWithFormat:@"batteryLevel: %ld",deviceInfo.batLevel];
    [deviceInfoHtml appendString:updateBatteryString];
    [deviceInfoHtml appendString:@"<br>"];
    return deviceInfoHtml;
}

- (NSString *)addsupportSportsListToHtml:(NSDictionary *)sportDic
{
    NSMutableString *supportSportListHtml = [[NSMutableString alloc] init];
    [supportSportListHtml appendString:[self formatearTitulo:@"Support Sports List"]];
    
    if (sportDic[@"raw_data"]) {
        [supportSportListHtml appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",sportDic[@"raw_data"]]];
    }
    
    [supportSportListHtml appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    NSArray *sportNumberArray = sportDic[@"SPORT_NUMBER"];
    NSArray *sportNameArray = sportDic[@"SPORT_NAME"];
    
    for (int i = 0; i< sportNumberArray.count; i++) {
        NSString *sportString = [NSString stringWithFormat:@"%d : %@",[sportNumberArray[i] intValue],sportNameArray[i]];
        [supportSportListHtml appendString:sportString];
        [supportSportListHtml appendString:@"<br>"];
    }
    return supportSportListHtml;
}

- (NSString *)addcurrentWholeDaySportDataToHtml:(NSDictionary *)sportData
{
    NSMutableString *currentSportData = [[NSMutableString alloc] init];
    [currentSportData appendString:[self formatearTitulo:@"CurrentWholeDaySportData"]];
    
    if (sportData[@"raw_data"]) {
        [currentSportData appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",sportData[@"raw_data"]]];
    }
    
    [currentSportData appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    NSString *sportDataString = [NSString stringWithFormat:@"steps: %d<br> calorie: %.1f<br> distance: %.1f<br> ",[sportData[@"steps"] intValue], [sportData[@"calorie"] floatValue], [sportData[@"distance"] floatValue]];
    [currentSportData appendString:sportDataString];
    [currentSportData appendString:@"<br>"];
    return currentSportData;
}

- (NSString *)addWholeDaySportDataToHtml:(NSDictionary *)sportData
{
    NSMutableString *wholeDaySportData = [[NSMutableString alloc] init];
    [wholeDaySportData appendString:[self formatearTitulo:@"WholeDaySportData"]];
    
    if (sportData[@"raw_data"]) {
        [wholeDaySportData appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",sportData[@"raw_data"]]];
    }
    [wholeDaySportData appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    NSString *sportDataString = [NSString stringWithFormat:@"date: %@<br> sport type: %@<br> steps: %d<br> calorie: %.1f<br> distance: %.1f<br> ",sportData[@"date"], sportData[@"sport_type"], [sportData[@"steps"] intValue], [sportData[@"calorie"] floatValue], [sportData[@"distance"] floatValue]];
    [wholeDaySportData appendString:sportDataString];
    [wholeDaySportData appendString:@"<br>"];
    return wholeDaySportData;
}

- (NSString *)addsportDataDetailToHtml:(NSDictionary *)sportDetail
{
    NSMutableString *sportDataDetail = [[NSMutableString alloc] init];
    [sportDataDetail appendString:[self formatearTitulo:@"SportDetail"]];
    
    if (sportDetail[@"raw_data"]) {
        [sportDataDetail appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",sportDetail[@"raw_data"]]];
    }
    [sportDataDetail appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    NSString *sportDetailString = [NSString stringWithFormat:@"sport type: %@<br> start time: %@<br> end time: %@<br>  steps: %d<br> calorie: %.1f<br> distance: %.1f<br> ",sportDetail[@"sport_type"], sportDetail[@"start_time"], sportDetail[@"end_time"], [sportDetail[@"steps"] intValue], [sportDetail[@"calorie"] floatValue], [sportDetail[@"distance"] floatValue]];
    
    [sportDataDetail appendString:sportDetailString];
    if (sportDetail[@"count"]) {
        [sportDataDetail appendString:[NSString stringWithFormat:@"count: %d <br>",[sportDetail[@"count"] intValue]]];
    }
    [sportDataDetail appendString:@"<br>"];
    return sportDataDetail;
}

- (NSString *)addsleepDataToHtml:(NSDictionary *)sleepData
{
    NSMutableString *sleepDataHtml = [[NSMutableString alloc] init];
    [sleepDataHtml appendString:[self formatearTitulo:@"SleepData"]];
    
    if (sleepData[@"raw_data"]) {
        [sleepDataHtml appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",sleepData[@"raw_data"]]];
    }
    [sleepDataHtml appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    NSString *sleepDataString = [NSString stringWithFormat:@"start time: %@<br> end time: %@<br>  sleep type: %@<br>",sleepData[@"start_time"], sleepData[@"end_time"], sleepData[@"sleep_type"]];
    
    [sleepDataHtml appendString:sleepDataString];
    [sleepDataHtml appendString:@"<br>"];
    
    return  sleepDataHtml;
}

- (NSString *)addheartRateDataHoursToHtml:(NSDictionary *)heartRateData
{
    NSMutableString *heartRateHours = [[NSMutableString alloc] init];
    [heartRateHours appendString:[self formatearTitulo:@"HeartRateDataHours"]];
    
    if (heartRateData[@"raw_data"]) {
        [heartRateHours appendString:[NSString stringWithFormat:@"RAW DATA: <br>%@<br><br>",heartRateData[@"raw_data"]]];
    }
    [heartRateHours appendString:[NSString stringWithFormat:@"PROCESSED DATA: <br>"]];
    
    [heartRateHours appendString:[NSString stringWithFormat:@"date: %@<br>",heartRateData[@"date"]]];
    
    NSArray *rate = heartRateData[@"rate"];
    
    for (int i = 0; i < rate.count; i++) {
        NSString *timeRate = [NSString stringWithFormat:@"%d<br>",[rate[i] intValue]];
        [heartRateHours appendString:timeRate];
    }
    [heartRateHours appendString:@"<br>"];
    
    return heartRateHours;
}



@end
