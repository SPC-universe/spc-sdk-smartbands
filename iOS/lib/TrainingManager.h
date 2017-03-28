#import <Foundation/Foundation.h>
#import "DeviceInfo.h"
#import "IwownBlePeripheral.h"
#import "BLELib3.h"


@protocol TrainingManagerDelegate <NSObject>

@optional

- (void)batteryInfoDidUpdate:(NSInteger)powerLevel;

@end

@interface TrainingManager : NSObject <IWBLEDiscoverDelegate, IWBLEConnectDelegate, BLELib3Delegate>

@property (nonatomic, assign) id <TrainingManagerDelegate> delegate;
@property (nonatomic, assign) kBLEstate state;
@property (nonatomic, assign) BOOL auto_reconnect_cancel;

+ (TrainingManager *) sharedInstance;

- (void)setAutoReconnect:(BOOL)isNeed andReconnectCheckTime:(NSTimeInterval)timeSec;

- (void)scanDevice;
- (void)stopScan;
- (NSArray *)getDevices;

- (void)connectDevice:(IwownBlePeripheral *)device;
- (kBLEstate)currentState;
- (BOOL)isConnected;
- (BOOL)isBinded;
- (void)unConnectDevice;
- (void)debind;

- (void)getDeviceInfo;
- (NSDictionary *)getSupportSportsList;
- (BOOL)getCurrentSportData;
- (void)getHRDataOfHours;
- (void)sportDataSwichOn:(BOOL)on;
- (void)setSportTarget:(NSMutableArray *)targetArray;

- (void)deviceReset;

- (BOOL)setScheduleAlert:(NSArray *)alertArray andRWQueueUsed:(BOOL)useRWQueue;
- (BOOL)setMotionRemender:(NSDictionary *)motionDict andRWQueueUsed:(BOOL)useRWQueue;
- (BOOL)setPersonalInfo:(NSDictionary *)infoDict andRWQueueUsed:(BOOL)useRWQueue;
- (BOOL)setHWOption:(NSDictionary *)hwoption  andRWQueueUsed:(BOOL)useRWQueue;
- (BOOL)syscTimeandRWQueueUsed:(BOOL)useRWQueue;
- (BOOL)syscMPSend:(NSDictionary *)mspdict andRWQueueUsed:(BOOL)useRWQueue;

@end

