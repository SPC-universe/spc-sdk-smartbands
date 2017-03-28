#import <Foundation/Foundation.h>

@interface SportManager : NSObject

@property (strong, nonatomic) NSDictionary *training;

+ (SportManager *)sharedInstance;
- (NSString *)sportKeyWithTrainingNumber:(NSNumber *)number;
- (NSNumber *)trainingNumberWithSportKey:(NSString *)key;

@end
