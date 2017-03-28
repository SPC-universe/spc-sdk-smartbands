#import <Foundation/Foundation.h>
#import "TrainingManager.h"

#define YMDHMS NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond

@interface DataManager : NSObject

@property (strong, nonatomic) NSDateFormatter *gmt;
@property (strong, nonatomic) NSDateFormatter *gmtYmd;
@property (strong, nonatomic) NSDateFormatter *gmtHS;
@property (strong, nonatomic) NSTimeZone *gmtTz;
@property (strong, nonatomic) NSCalendar *gmtCalendar;
@property (strong, nonatomic) NSDateFormatter *Ymdhms;
@property (strong, nonatomic) NSDateFormatter *gmtYmdHms;

@property(strong, nonatomic) TrainingManager *trainingManager;
@property(strong, nonatomic) IwownBlePeripheral *selectedDevice;

@property (nonatomic) BOOL man;
@property (nonatomic) NSNumber *goal;

+ (DataManager *)sharedInstance;

- (void)scanDevice;
- (void)stopScan;
- (NSArray *)getDevices;
- (void)connectDevice:(IwownBlePeripheral *)device;
- (void)disconnectDevice;
- (void)debind;
- (BOOL)isConnected;
- (void)deviceReset;

- (void)getDeviceInfo;
- (void)getSupportSportsList;
- (void)getCurrentSportData;
- (void)getHRDataOfHours;
- (void)sportDataSwitchOn:(BOOL)on;
- (void)setSportTarget:(NSMutableArray *)targetArray;

- (NSString *)headertHtml;
- (NSString *)endHTml;
- (NSString *)addDeviceInfoToHtml:(DeviceInfo *)deviceInfo;
- (NSString *)addUpdateBatteryToHtml:(DeviceInfo *)deviceInfo;
- (NSString *)addsupportSportsListToHtml:(NSDictionary *)sportDic;
- (NSString *)addcurrentWholeDaySportDataToHtml:(NSDictionary *)sportData;
- (NSString *)addWholeDaySportDataToHtml:(NSDictionary *)sportData;
- (NSString *)addsportDataDetailToHtml:(NSDictionary *)sportDetail;
- (NSString *)addsleepDataToHtml:(NSDictionary *)sleepData;
- (NSString *)addheartRateDataHoursToHtml:(NSDictionary *)heartRateData;

@end
