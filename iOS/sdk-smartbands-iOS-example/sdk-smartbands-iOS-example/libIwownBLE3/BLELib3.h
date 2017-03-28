//
//  BLELib3.h
//  BLELib3
//
//  Created by 曹凯 on 15/10/26.
//  Copyright © 2015年 Iwown. All rights reserved.
//

#import "IwownModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCAN_TIME_INTERVAL 5

typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected ,
    kBLEstateBindUnConnected ,
}kBLEstate;

@class IwownBlePeripheral;
@class DeviceInfo;

@protocol IWBLEDiscoverDelegate <NSObject>

@required

- (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice;

@optional
/**
 *  @return the service did protocoled, for bracelet ,you could write @"FF20" ,you also can never implement this method for connect bracelet.
 */
- (NSString *)serverUUID;

@end

/*------------------------------------------------------------*/

@protocol IWBLEConnectDelegate <NSObject>

@required
/**
 *  invoked when the device did connected by the central
 *
 *  @param device : the device did connected
 */
- (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device;

@optional
/**
 *  invoked when the device did fail to connected by the central
 *
 *  @param device : the device whom the central want to be connected
 */
- (void)IWBLEDidFailToConnectDevice:(IwownBlePeripheral *)device andError:(NSError *)error;

/**
 *  this method would be called when the Peripheral disConnected with the system; In this case ,your app should tell the user who could ingore the device on system bluetooth ,and reconnect the device. or there will be risk of receiving a message reminder.
 *
 *  @param deviceName the Device Name
 */
- (void)deviceDidDisConnectedWithSystem:(NSString *)deviceName;

@end

/*------------------------------------------------------------*/

@protocol BLELib3Delegate <NSObject>

#pragma mark -/****************************===device setting===*****************************************/

@required
/*
 * set bracelet parameter after connect with phone.
 */
- (void)setBLEParameterAfterConnect;

#pragma mark -/****************************===device function===*****************************************/

@optional
/*
 * description: app invoke setKeyNotify:1，let bracelet enter into photograpy mode, bracelet show take photo button, press
 *              it, sdk will notify app to take photo by invoke notifyToTakePicture
 *
 * notice: setKeyNotify - set 1 to enter into easycamera mode, 
 *                        set 0 to exit
 *      need mechanism to do photo protection, make sure not start next photography before
 *      saving last photo completed
 */
- (void)notifyToTakePicture;

/*
 * description: long press bracelet button or touch screen to select find phone button, sdk invoke
 *       notifyToSearchPhone to notify app the bracelet need find phone, then app can play related music
 *        or proceed other action.
 */
- (void)notifyToSearchPhone;

#pragma mark -/****************************===device Info===*****************************************/

- (void)updateDeviceInfo:(DeviceInfo*)deviceInfo;
- (void)updateBattery:(DeviceInfo *)deviceInfo;

/**
 *  the method be called after call - (void)getSupportSportsList;
 *
 *  @param ssList
 */
- (void)notifySupportSportsList:(NSDictionary *)ssList;

/**
 *  responseOfGetTime
 *
 *  @param date (year month day hour minute second)
 */
- (void)responseOfGetTime:(NSDate *)date;

/**
 *  the response of get clock
 *
 *  @param clock
 */
- (void)responseOfGetClock:(IwownClock *)clock;

/**
 *  the response of get sedentary
 *
 *  @param sedentary
 */
- (void)responseOfGetSedentary:(IwownSedentary *)sedentary;

/**
 *  the response of get HWOption
 *
 *  @param hwOption
 */
- (void)responseOfGetHWOption:(IwownHWOption *)hwOption;

- (void)responseOfGetSprotTarget:(IwownSportTarget *)spModel;

#pragma mark -/****************************===device data===*****************************************/

/**
 *  this method be called when the sdk have sleep data update;
 *
 *  @param dict
 */
- (void)updateSleepData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have sport data update;
 *
 *  @param dict
 */
- (void)updateSportData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have day sport data update;
 *
 *  @param dict
 */
- (void)updateWholeDaySportData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have HeartRate data update;
 *
 *  @param dict
 */
//- (void)updateHeartRateData:(NSDictionary *)dict;

- (void)updateHeartRateData_hours:(NSDictionary *)dict;

/**
 *   this method be called when the sdk have current sport data update;
 *
 *  @param dict
 */
//- (void)updateCurrentSportData:(NSDictionary *)dict;
/**
 *   this method be called when the sdk have current day sport data update;
 *
 *  @param dict
 */
- (void)updateCurrentWholeDaySportData:(NSDictionary *)dict;

/**
 *   this method be called when the sdk have current HeartRate data update;
 *
 *  @param dict
 */
- (void)updateCurrentHeartRateData:(NSDictionary *)dict DEPRECATED_ATTRIBUTE;

/**
 *  response for set a schedule
 *
 *  @param success YES - NO
 */
- (void)responseOfScheduleSetting:(BOOL)success;

/**
 *  response for get a schedule
 *
 *  @param exist YES 存在   NO 不存在
 */
- (void)responseOfScheduleGetting:(BOOL)exist;


/**
 *  respone of get schedule information read
 *
 *  @param dict  dict[@"cur_num"] 可配置日程数量   dict[@"all_num"]:日程最大数量  dict[@"day_num"]:每天可配置日程数量
 */
- (void)responseOfScheduleInfoGetting:(NSDictionary *)dict;

@end

/*------------------------------------------------------------*/

typedef enum {
    CurrentBLEProtocol2_0 = 0,
    CurrentBLEProtocol3_0
} CurrentBLEProtocol;

@interface BLELib3 : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, assign) id <BLELib3Delegate> delegate;
@property (nonatomic, assign) id <IWBLEConnectDelegate> connectDelegate;
@property (nonatomic, assign) id <IWBLEDiscoverDelegate> discoverDelegate;

@property (nonatomic ,assign) CurrentBLEProtocol protocolVSN;

+ (instancetype)shareInstance;

- (NSString *)libBleSDKVersion;

@property (nonatomic ,assign) kBLEstate state; //support add observer ,abandon @readonly ,don't change it anyway.

@property (nonatomic ,readonly) CBPeripheral *currentDevice;

#pragma mark - action of connecting layer

- (void)scanDevice;
- (void)stopScan;
- (void)connectDevice:(IwownBlePeripheral *)dev;
- (void)unConnectDevice;
- (void)reConnectDevice;
- (NSArray *)retrieveConnectedPeripherals;

- (void)debindFromSystem;

#pragma mark - action of data layer

/**
 *  call this method get the supported sports list on current bracelet .@see {@link notifySupportSportsList:}
 */
- (void)getSupportSportsList;

/**
 *  call this method get current sports data; you could run a timer to do this. then you get data what you want  @see {@link updateWholeDaySportData:}
 */
- (void)getCurrentSportData;

/**
 *  call this method get current connected device's info @see {@link updateDeviceInfo:} And {@link updateBattery:}
 */
- (void)getDeviceInfo;

/**
 *  reset device
 */
- (void)deviceReset;

/**
 *  it's for channel 28、29、51, when update heart rate module need shutdown this
 */
- (void)sportDataSwichOn:(BOOL)on;

/**
 *  get parameters of heart rate module
 */
- (void)getHRParam;

/**
 *  request time shared heart rate data
 */
- (void)getHRDataOfHours;

#pragma mark -action of setting layer

/**
 *  control whether need write device setting when reconnect
 *
 */
@property (nonatomic ,assign) BOOL isResetFWSettingNeed;

#pragma mark -/****************************===device setting===*****************************************/

- (void)syscTimeAtOnce;

- (void)setMessagePush:(IwownMESPush *)mspModel;
- (void)setAlertMotionReminder:(IwownSedentary *)sedentaryModel;
- (void)setPersonalInfo:(IwownPersonal *)personalModel;
- (void)setScheduleClock:(IwownClock *)clockModel;
- (void)setFirmWareOption:(IwownHWOption *)hwOptionModel;

/******************************************************************************************
 * array [ Monday array, Tuesday array, Wednesday array, ...]
 * Monday array [ dict, dict, dict, ...]
 * dict {@"TARGET":@"100", @"TYPE":@"01",...}
 * be aware type and target is decimal number
 *******************************************************************************************/
- (void)setSportTarget:(NSMutableArray *)targetArray;

- (void)setSportTargetBy:(IwownSportTarget *)st;

/**
 * Write heart rate parameters
 * hrIntensity (Exercise intensity);
 * Alarm time units is minute , default is 10 minutes. if you write an number 0, the default num will be valid.
 
 * write heart rate parameters
 * hrIntensity sport intensity
 */
- (void)setHRParamData:(NSUInteger)hrIntensity andAlarmTime:(NSUInteger)time;

#pragma mark -action of feature layer - Functional layer operation

/**
 * Push the string, e.g.： [iwownBLE pushStr:@"This is a test example"];
 */
- (void)pushStr:(NSString *)str;

/**
 *  send command to bracelet to enter into firmware update mode
 *  only device support firmware update need this (I5PLUS, I7 support, I5, I6 not support)
 */
- (void)deviceUpdate;

/**
 *  necessary for heart rate module upgrade
 *  but not support heart rate upgrade at present
 */
- (void)writeHeartRateUpdateCharacteristicData:(NSString *)str;

/**
 * call this method to become smart photo or exits. 
 * set 1 to active (show take picture button)
 * set 0 to exit (hide take picture button)
 * to get photos @see -> (void)notifyToTakePicture;
 */
- (void)setKeyNotify:(NSUInteger)keyNotify;

/**
 *  Default is NO. set YES abandon general read/write operation, use when heart rate module upgrade.
 *  after upgrade finish, need revert
 */
- (void)setWriteDataForbidden:(BOOL)forbidden;

#pragma mark Schedule

// write schedule
- (void)writeSchedule:(IwownSchedule *)sModel;

// clear all schedules
- (void)clearAllSchedule;

// remove schedule
- (void)closeSchedule:(IwownSchedule *)sModel;

// get schedule information
- (void)readScheduleInfo;

// get specified schedule
- (void)readSchedule:(IwownSchedule *)sModel;

@end
