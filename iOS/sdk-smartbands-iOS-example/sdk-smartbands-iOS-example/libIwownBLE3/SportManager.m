#import "SportManager.h"

@interface SportManager ()

@end

@implementation SportManager

+ (SportManager *)sharedInstance
{
    static SportManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SportManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.training =
    @{
      @1   : @"WALKING",        // 0x01 walk
      @2   : @"SITE_UPS",       // 0x02 situp
      @3   : @"PUSH_UP",        // 0x03 push-up
      @4   : @"ROPE_SKIPPING",  // 0x04 rope skippingß
      @5   : @"MOUNTAINEERING", // 0x05 climb
      @6   : @"PULL_UP",        // 0x06 pull-up
      @128 : @"BADMINTON",      // 0x80 badminton
      @129 : @"BASKETBALL",     // 0x81 basketball
      @130 : @"FOOTBALL",       // 0x82 football
      //@131 : @"SWIM",           // 0x83 swim
      @132 : @"VOLLEYBALL",     // 0x84 volleyball
      @133 : @"TABLE_TENNIS",   // 0x85 pingpong
      @134 : @"BOWLING",        // 0x86 bowling
      @135 : @"TENNIS",         // 0x87 tennis
      @136 : @"CYCLING",        // 0x88 cycling
      @137 : @"SKI",            // 0x89 ski
      @138 : @"SKATE",          // 0x8a skating
      @139 : @"ROCK_CLIMBING",  // 0x8b rock climbing
      @140 : @"GYM",            // 0x8c gym
      @141 : @"DANCE",          // 0x8d dance
      @142 : @"TABLET_SUPPORT", // 0x8e tablet support
      @143 : @"GYM_EXERCISE",   // 0x8f gym exercise
      @144 : @"YOGA",           // 0x90 yoga
      @145 : @"SHUTTLECOCK",    // 0x91 shuttlecock
      };

}

#pragma mark Sport Data

- (NSString *)sportKeyWithTrainingNumber:(NSNumber *)number
{
    return self.training[number];
}

- (NSNumber *)trainingNumberWithSportKey:(NSString *)key
{
    for (NSNumber *number in self.training) {
        if ([self.training[number] isEqualToString:key]) {
            return number;
        }
    }
    return nil;
}

@end
