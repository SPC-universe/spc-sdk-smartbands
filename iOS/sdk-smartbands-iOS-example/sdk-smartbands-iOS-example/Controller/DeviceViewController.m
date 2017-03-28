#import "DeviceViewController.h"
#import "DataManager.h"

@interface DeviceViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) NSTimer *waitDisconnetedState;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (weak, nonatomic) IBOutlet UILabel *selectedDevice;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *deviceStatus;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    [self.waitDisconnetedState invalidate];
    self.waitDisconnetedState = nil;
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    self.baseURL = [NSURL fileURLWithPath:path];
    self.htmlbody = [[NSMutableString alloc] init];
    [self initHtml];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setupNotifications];
    [self updateUI];
}

- (void)updateUI
{
    if (self.dataManager.selectedDevice) {
        self.selectedDevice.text = self.dataManager.selectedDevice.deviceName;
    }
    
    [self updateDeviceStatus:[self.dataManager isConnected]];
    
    [self updateWebView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
}

- (void)updateWebView
{
    [self.webView loadHTMLString:[self formatearHTML] baseURL:self.baseURL];
}

#pragma device Status

- (void)updateDeviceStatus:(BOOL)status
{
    if (status) {
        self.deviceStatus.text = @"Connected";
        self.deviceStatus.textColor = [UIColor greenColor];
    } else {
        self.deviceStatus.text = @"Disconnected";
        self.deviceStatus.textColor = [UIColor redColor];
    }
}

#pragma Actions

- (IBAction)connect:(UIButton *)sender {
    if (self.dataManager.selectedDevice) {
        [self.activityIndicator startAnimating];
        [self.dataManager connectDevice:self.dataManager.selectedDevice];
    }
}

- (IBAction)disconnect:(UIButton *)sender {
    if (self.dataManager.selectedDevice && [self.dataManager isConnected]) {
        [self.dataManager disconnectDevice];
        [self.dataManager debind];
        self.waitDisconnetedState =
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(checkDisconnectedState)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)checkDisconnectedState {
    NSLog(@"checkDisconnectedState");
    
    [self.waitDisconnetedState invalidate];
    self.waitDisconnetedState = nil;
    
    if (![self.dataManager isConnected]) {
        [self updateDeviceStatus:[self.dataManager isConnected]];
        [self.htmlbody setString:@""];
        [self updateWebView];
    } else {
        self.waitDisconnetedState =
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(checkDisconnectedState)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (IBAction)showCommands:(id)sender {
    if ([self.dataManager isConnected]) {
        [self performSegueWithIdentifier:@"Commands" sender:self];
    } else {
        [self showAlert:@"Can't send commands if a device is not connected. Connect a device first." title:@"Connect a device"];
    }
    
//    // Comment the line behind and uncomment the lines above
//    [self performSegueWithIdentifier:@"Commands" sender:self];
}

#pragma mark Notifications

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(updateDeviceInfo:)
                   name:@"updateDeviceInfo"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(updateBattery:)
                   name:@"updateBattery"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(iwownDisconnectedNotification:)
                   name:@"IwownDisconnectedNotification"
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

- (void)updateDeviceInfo:(NSNotification *)notification {
    NSLog(@"DeviceViewController - updateDeviceInfo: %@", notification);
    [self.activityIndicator stopAnimating];
    if (notification.object && [notification.object isKindOfClass:[DeviceInfo class]]) {
        [self addDeviceInfoToHtml:notification.object];
    }
    [self updateUI];
}

- (void)updateBattery:(NSNotification *)notification {
    NSLog(@"DeviceViewController - updateBattery: %@", notification);
    [self.activityIndicator stopAnimating];
    if (notification.object && [notification.object isKindOfClass:[DeviceInfo class]]) {
        [self addUpdateBatteryToHtml:notification.object];
    }
    [self updateUI];
}

- (void)iwownDisconnectedNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - iwownDisconnectedNotification: %@", notification);
    [self.activityIndicator stopAnimating];
    [self updateUI];
}

- (void)supportSportsListNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - supportSportsListNotification: %@", notification);
    if (notification.userInfo) {
        [self addsupportSportsListToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)currentWholeDaySportDataNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - currentWholeDaySportDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addcurrentWholeDaySportDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)wholeDaySportDataNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - wholeDaySportDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addWholeDaySportDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)sportDataDetailNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - sportDataDetailNotification: %@", notification);
    if (notification.userInfo) {
        [self addsportDataDetailToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)heartRateDataHoursNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - heartRateDataHoursNotification: %@", notification);
    if (notification.userInfo) {
        [self addheartRateDataHoursToHtml:notification.userInfo];
    }
    [self updateUI];
}

- (void)sleepDataNotification:(NSNotification *)notification
{
    NSLog(@"DeviceViewController - sleepDataNotification: %@", notification);
    if (notification.userInfo) {
        [self addsleepDataToHtml:notification.userInfo];
    }
    [self updateUI];
}

#pragma mark TextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (void)addUpdateBatteryToHtml:(DeviceInfo *)deviceInfo
{
    [self.htmlbody appendString:[self.dataManager addUpdateBatteryToHtml:deviceInfo]];
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

#pragma mark - Alert

- (void)showNotConnectedAlert
{
    [self showAlert:@"Device not connected" title:@"Device Disconnected"];
}

- (void)showAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok", nil];
    [alert show];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}

@end
