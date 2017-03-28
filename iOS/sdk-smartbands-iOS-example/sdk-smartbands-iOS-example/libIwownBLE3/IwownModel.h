//
//  IwownModel.h
//  Demo
//
//  Created by 曹凯 on 15/12/25.
//  Copyright © 2015年 Iwown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IwownBleHeader.h"

@interface IwownModel : NSObject <NSCoding>
@end

/*------------------------------------------------------------*/
@interface IwownClock : IwownModel <NSCoding>
+ (instancetype)defaultClock;

/**
 * switch of clock ,defalult is NO.
 * switch state of alarm, default is closed
 */
@property (nonatomic ,assign) BOOL switchStatus;

/**
 * this attribute denote that is this clock viable ,default is no.
 * represent whether the alarm is visible, the deleted alarm or the alarm number is not added
 * which is invisible
 */
@property (nonatomic ,assign) BOOL viable;

/**
 * index of clock ,valiable range is 0～7.
 * alarm index, support 8 alarm, index range from 0~7
 */
@property (nonatomic ,assign) NSUInteger clockId;
@property (nonatomic ,readonly ,assign) NSUInteger clockType;

/* *
 * 0xff    b7 repeated mark  b6:Mon    b5:Tue  b4:Wed   b3:Thu   b2:Fri   b1:Sat   b0:Sun
 * 1 means open, 0 means close
 */
@property (nonatomic ,assign) NSUInteger weekRepeat;
@property (nonatomic ,assign) NSUInteger clockHour;
@property (nonatomic ,assign) NSUInteger clockMinute;
@property (nonatomic ,assign) NSUInteger clockTipsLenth DEPRECATED_ATTRIBUTE;
@property (nonatomic ,strong) NSString *clockTips DEPRECATED_ATTRIBUTE;

@end

/*------------------------------------------------------------*/
@interface IwownSedentary : IwownModel <NSCoding>
+ (instancetype)defaultSedentary;

/**
 * the state of reminder switch, default is NO ,means off.
 */
@property (nonatomic ,assign) BOOL switchStatus;
@property (nonatomic ,assign) NSUInteger sedentaryId DEPRECATED_ATTRIBUTE;

/**
 * the repeats of sedentary ,to know more details to see @code checkBoxStateChanged methods。
 */
@property (nonatomic ,assign) NSUInteger weekRepeat ;

/**
 * the startTime of sedentary ,unit id hour .
 */
@property (nonatomic ,assign) NSUInteger startHour;

/**
 * the endTime of sedentary ,unit id hour .
 */
@property (nonatomic ,assign) NSUInteger endHour;

@property (nonatomic ,assign) NSUInteger sedentaryDuration DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) NSUInteger sedentaryThreshold DEPRECATED_ATTRIBUTE;

@end

/*------------------------------------------------------------*/
typedef enum{
    UnitTypeInternational = 0, // International units ,like km、meter、kg .
    UnitTypeEnglish            // Imperial units ,like feet、inch、pound .
}UnitType;

typedef enum{
    TimeFlag24Hour = 0,
    TimeFlag12Hour
}TimeFlag;

typedef enum{
    braceletLanguageEnglish = 0,
    braceletLanguageSimpleChinese
}braceletLanguage;

@interface IwownHWOption : IwownModel <NSCoding>
+ (instancetype)defaultHWOption;

/**
 * switch of led light ,default is NO ,brcelet i7 is not supported .
 */
@property (nonatomic ,assign) BOOL ledSwitch;

/**
 * switch of wrist ,default is YES.
 */
@property (nonatomic ,assign) BOOL wristSwitch;

/**
 * switch of unitType changed ,default is UnitTypeInternational.
 */
@property (nonatomic ,assign) UnitType unitType;

/**
 * switch of timeFlag changed ,default is TimeFlag24Hour.
 */
@property (nonatomic ,assign) TimeFlag timeFlag;

/**
 * switch of autoSleep ,default is YES ,that means bracelet recognize sleep state automatically .
 */
@property (nonatomic ,assign) BOOL autoSleep;

@property (nonatomic ,assign) BOOL advertisementSwitch DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) NSUInteger backlightStart; // DEPRECATED_ATTRIBUTE
@property (nonatomic ,assign) NSUInteger backlightEnd; // DEPRECATED_ATTRIBUTE

/**
 *  backColor for I7, default is NO.  YES is white，NO is black
 */
@property (nonatomic, assign) BOOL backColor; // DEPRECATED_ATTRIBUTE

/**
 * switch of what's language bracelet is used ,default is braceletLanguageSimpleChinese ,to know more about language that bracelet supported. @see braceletLanguage .
 */
@property (nonatomic ,assign) braceletLanguage language;

/**
 *  switch of disConnectTip, default is NO ,default is close the tips 0f disConnect.
 */
@property (nonatomic, assign) BOOL disConnectTip DEPRECATED_ATTRIBUTE;

@end

/*------------------------------------------------------------*/
@interface IwownPersonal : IwownModel <NSCoding>

+ (instancetype)defaultPersonalModel;
/**
 * height of personal setting , unit is cm .default is 170.
 */
@property (nonatomic ,assign) NSUInteger height;

/**
 * weight of personal setting , unit is kg .default is 60.
 */
@property (nonatomic ,assign) NSUInteger weight;

/**
 * gender of personal setting ,0 represent male ,1 represent female .default is 0 .
 */
@property (nonatomic ,assign) NSUInteger gender;

/**
 * age of personal setting .default is 20.
 */
@property (nonatomic ,assign) NSUInteger age;

//@property (nonatomic ,assign) NSUInteger target DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) NSUInteger target;

@end

/*------------------------------------------------------------*/
@interface IwownMESPush : IwownModel <NSCoding>

+ (instancetype)defaultMESPushModel;

/**
 * there are some attributes setting with message push ,the switch is setting yes ,
 * the message of this social contact and which did show in apple notification center 
 * would pushed to your bracelet and notice it .
 * Default is YES . @note make sure your bracelet is connectted with the iphone‘s sysctem.
 */
@property (nonatomic ,assign) BOOL iphoneSwitch DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) BOOL msgSwitch DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) BOOL qqSwitch;
@property (nonatomic ,assign) BOOL wechatSwitch;
@property (nonatomic ,assign) BOOL facebookSwitch;
@property (nonatomic ,assign) BOOL twitterSwitch;
@property (nonatomic ,assign) BOOL skypeSwitch;
@property (nonatomic ,assign) BOOL whatsappSwitch;

@end

/*------------------------------------------------------------*/
@interface SportModel : IwownModel <NSCoding>

@property (nonatomic,assign)NSString *sportName;
@property (nonatomic,strong,readonly)NSString *unit;
@property (nonatomic,assign)sd_sportType type;
@property (nonatomic,assign)NSInteger targetNum;

@end

/*------------------------------------------------------------*/
@interface IwownSportTarget : IwownModel <NSCoding>

+ (instancetype)defaultSportTargetModel;

@property (nonatomic,assign)NSInteger day;

/**
 *  add sport mode, the first should be walk which bracelet take as default
 */
@property (nonatomic,strong)NSMutableArray *sportArr;

- (void)addSportModel:(SportModel *)sm;

@end

/*------------------------------------------------------------*/
@interface IwownSchedule : NSObject

typedef enum {
    ScheduleUnSetting = 0,
    ScheduleSetting = 1,
    ScheduleUnvalid = 2,
}ScheduleState;

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;

@property(nonatomic,assign)NSInteger year;
@property(nonatomic,assign)NSInteger month;
@property(nonatomic,assign)NSInteger day;

@property(nonatomic,assign)NSInteger hour;
@property(nonatomic,assign)NSInteger minute;

@property(nonatomic,assign)NSInteger state;

- (instancetype)initWithTitile:(NSString *)title subTitle:(NSString *)subTitle year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;

@end

