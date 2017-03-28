//
//  DeviceInfo.h
//  ZLingyi
//
//  Created by Jackie on 15/1/29.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

@property (nonatomic,strong)    NSString *model;        // model string
@property (nonatomic,strong)    NSString *version;      // version string
@property (nonatomic,readonly)  NSUInteger versionValue;// integer value of version
@property (nonatomic,readonly)  NSUInteger oadMode;     // over air update mode
@property (nonatomic,readonly)  NSUInteger batLevel;    // battery level
@property (nonatomic,strong)    NSString *seriesNo;      // series No. ble Addr for display
@property (nonatomic,strong)    NSString *bleAddr;      // series No. ble Addr for upload
@property (nonatomic,readonly)  NSUInteger customNo;      // custom number，0 means ourselves

@property (nonatomic,strong)  NSString *hrVersion;    //heart rate module version
@property (nonatomic,assign)  NSInteger hrVersionValue; //heart rate module version number

@property (nonatomic,strong)    NSString *fontSupport;  //0 null ,1 e&&c ,2 128国

+(instancetype)defaultDeviceInfo;

- (void)updateDeviceInfo:(NSString *)deviceInfo;
- (void)updateBattery:(NSString *)batteryLevel;

- (void)updateHeartRateParam:(NSString *)body;

@end
