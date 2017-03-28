//
//  ScaleBLEShareInstance.h
//  ZLingyi
//
//  Created by Jackie on 14-7-10.
//  Copyright (c) 2014年 iWown. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCALEE_SERVICE_UUID                 @"FFF0"
#define SCALE_CHARACTERY_UUID               @"FFF6"

@protocol ScaleBLEShareInstanceDelegate <NSObject>

@required

- (NSDictionary *)scaleUserInfoDict;

- (void)didConnectedPeripheralNotice;

- (void)scaleBLEData:(NSMutableDictionary *)scaleData;

- (void)scaleWeightOnlyData:(NSMutableDictionary *)scaleData;

- (void)showTemporaryWeight:(CGFloat)weight;

@end

@interface ScaleBLEShareInstance : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager    *centralManager;
}

@property (strong) CBPeripheral     *connectingPeripheral;
@property (assign) NSInteger        notifyTime;
@property (assign) id <ScaleBLEShareInstanceDelegate>delegate;

+(ScaleBLEShareInstance *) shareInstance;

- (void) scanDevice;
- (void) stopScanDevice;
- (NSMutableDictionary *) scaleDataParsing:(NSString *)str;

@end
