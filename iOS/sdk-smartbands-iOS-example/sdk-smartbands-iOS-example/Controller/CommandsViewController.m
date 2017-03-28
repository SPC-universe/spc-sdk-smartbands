#import "CommandsViewController.h"
#import "DataManager.h"

@interface CommandsViewController () <UIWebViewDelegate>

@property (strong, nonatomic) DataManager *dataManager;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CommandsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.dataManager = [DataManager sharedInstance];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    self.baseURL = [NSURL fileURLWithPath:path];
    self.htmlbody = [[NSMutableString alloc] init];
    [self initHtml];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupNotifications];
    [self updateUI];
}

- (void)updateUI
{
    [self.webView loadHTMLString:[self formatearHTML] baseURL:self.baseURL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
}

#pragma mark Notifications

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(updateDeviceInfo:)
                   name:@"updateDeviceInfo"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(supportSportsListNotification:)
                   name:@"SupportSportsListNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(currentWholeDaySportDataNotification:)
                   name:@"CurrentWholeDaySportDataNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(wholeDaySportDataNotification:)
                   name:@"WholeDaySportDataNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(sportDataDetailNotification:)
                   name:@"SportDataDetailNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(heartRateDataHoursNotification:)
                   name:@"HeartRateDataHoursNotification"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(sleepDataNotification:)
                   name:@"SleepDataNotification"
                 object:nil];
    
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma Actions

- (IBAction)getDeviceInfo:(id)sender
{
    [self.dataManager getDeviceInfo];
}

- (IBAction)getSupportSportList:(id)sender
{
    [self.dataManager getSupportSportsList];
}

- (IBAction)getCurrentSportData:(id)sender
{
    [self.dataManager getCurrentSportData];
}

- (IBAction)sportDataSwitchOn:(id)sender
{
    [self.dataManager sportDataSwitchOn:YES];
}

- (IBAction)getHRDataOfHours:(id)sender
{
    [self.dataManager getHRDataOfHours];
}

#pragma Notifications Selectors

- (void)updateDeviceInfo:(NSNotification *)notification {
    NSLog(@"CommandsViewController - updateDeviceInfo: %@", notification);
    if (notification.object && [notification.object isKindOfClass:[DeviceInfo class]]) {
        [self addDeviceInfoToHtml:notification.object];
    }
    [self updateUI];
}

- (void)supportSportsListNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - supportSportsListNotification: %@", notification);
    if (notification.userInfo) {
        [self addsupportSportsListToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)currentWholeDaySportDataNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - currentWholeDaySportDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addcurrentWholeDaySportDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)wholeDaySportDataNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - wholeDaySportDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addWholeDaySportDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)sportDataDetailNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - sportDataDetailNotification: %@", notification);
    if (notification.userInfo) {
        [self addsportDataDetailToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)heartRateDataHoursNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - heartRateDataHoursNotification: %@", notification);
    if (notification.userInfo) {
        [self addheartRateDataHoursToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)sleepDataNotification:(NSNotification *)notification
{
    NSLog(@"CommandsViewController - sleepDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addsleepDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

#pragma Format HTML

- (void)initHtml
{
    self.htmlHeader = self.dataManager.headertHtml;
    self.htmlEnd = self.dataManager.endHTml;
}

- (NSString *)formatearHTML
{
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:self.htmlHeader];
    [htmlCode appendString:self.htmlbody];
    [htmlCode appendString:self.htmlEnd];
    return htmlCode;
}

- (void)addDeviceInfoToHtml:(DeviceInfo *)deviceInfo
{
    [self.htmlbody appendString:[self.dataManager addDeviceInfoToHtml:deviceInfo]];
}

- (void)addsupportSportsListToHtml:(NSDictionary *)sportDic
{
    [self.htmlbody appendString:[self.dataManager addsupportSportsListToHtml:sportDic]];
}

- (void)addcurrentWholeDaySportDataToHtml:(NSDictionary *)sportData
{
    [self.htmlbody appendString:[self.dataManager addcurrentWholeDaySportDataToHtml:sportData]];
}

- (void)addWholeDaySportDataToHtml:(NSDictionary *)sportData
{
    [self.htmlbody appendString:[self.dataManager addWholeDaySportDataToHtml:sportData]];
}

- (void)addsportDataDetailToHtml:(NSDictionary *)sportDetail
{
    [self.htmlbody appendString:[self.dataManager addsportDataDetailToHtml:sportDetail]];
}

- (void)addsleepDataToHtml:(NSDictionary *)sleepData
{
    [self.htmlbody appendString:[self.dataManager addsleepDataToHtml:sleepData]];
}

- (void)addheartRateDataHoursToHtml:(NSDictionary *)heartRateData
{
    [self.htmlbody appendString:[self.dataManager addheartRateDataHoursToHtml:heartRateData]];
}

#pragma UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    int height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %d);", height];
    [webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"CommandsViewController - webView didFailLoadWithError - error: %@", error);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
