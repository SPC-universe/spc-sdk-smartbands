#import "AlarmViewController.h"
#import "DataManager.h"

@interface AlarmViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *indexPicker;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *viableSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;

@property (weak, nonatomic) IBOutlet UIButton *monday;
@property (weak, nonatomic) IBOutlet UIButton *tuesday;
@property (weak, nonatomic) IBOutlet UIButton *wednesday;
@property (weak, nonatomic) IBOutlet UIButton *thursday;
@property (weak, nonatomic) IBOutlet UIButton *friday;
@property (weak, nonatomic) IBOutlet UIButton *saturday;
@property (weak, nonatomic) IBOutlet UIButton *sunday;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (strong, nonatomic) NSMutableDictionary *dayState;
@property int repeat;
@property BOOL viableState;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    self.dayState = [[NSMutableDictionary alloc] initWithDictionary:@{@"monday"   : @(NO),
                      @"tuesday"  : @(NO),
                      @"wednesday": @(NO),
                      @"thursday" : @(NO),
                      @"friday"   : @(NO),
                      @"saturday" : @(NO),
                      @"sunday"   : @(NO),
                      }];
    self.repeat = 0x80;
    self.viableState = NO;
    [self.timePicker setDate:[NSDate date]];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    self.baseURL = [NSURL fileURLWithPath:path];
    self.htmlbody = [[NSMutableString alloc] init];
    [self initHtml];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateUI];
}

- (void)updateUI
{
    [self.webView loadHTMLString:[self formatearHTML] baseURL:self.baseURL];
}

#pragma Actions

- (IBAction)viableStateChanged:(UISwitch *)sender
{
    self.viableState = [self.viableSwitch isOn];
}

- (IBAction)repeatStateChanged:(UISwitch *)sender
{
    if ([sender isOn]) {
        self.repeat = self.repeat | 0x80;
    } else {
        self.repeat = self.repeat & ~0x80;
    }
}

- (IBAction)dayStateChanged:(UIButton *)sender
{
    BOOL state = NO;
    NSString *key = @"";
    int mask = 0x0;
    
    if ([sender isEqual:self.monday]) {
        key = @"monday";
        mask = 0x40;
    } else if ([sender isEqual:self.tuesday]) {
        key = @"tuesday";
        mask = 0x20;
    } else if ([sender isEqual:self.wednesday]) {
        key = @"wednesday";
        mask = 0x10;
    } else if ([sender isEqual:self.thursday]) {
        key = @"thursday";
        mask = 0x08;
    } else if ([sender isEqual:self.friday]) {
        key = @"friday";
        mask = 0x04;
    } else if ([sender isEqual:self.saturday]) {
        key = @"saturday";
        mask = 0x02;
    } else if ([sender isEqual:self.sunday]) {
        key = @"sunday";
        mask = 0x01;
    }
    
    state = ![self.dayState[key] boolValue];
    [self.dayState setValue:@(state) forKey:key];
    if (state) {
        self.repeat = self.repeat | mask;
    } else {
        self.repeat = self.repeat & ~mask;
    }
    [sender setSelected:state];
}

- (IBAction)setAlarm:(UIButton *)sender
{
    IwownClock *clockModel = [self createAlarmObject];

    [self addAlarmToHtml:clockModel];
    [[BLELib3 shareInstance] setScheduleClock:clockModel];
}

- (IBAction)removeAlarm:(UIButton *)sender
{
    IwownClock *clockModel = [self createAlarmObject];
    [clockModel setWeekRepeat:0];
    
    [self addAlarmToHtml:clockModel];
    [[BLELib3 shareInstance] setScheduleClock:clockModel];
}

- (IwownClock*)createAlarmObject
{
    IwownClock *clockModel = [IwownClock defaultClock];
    
    int index = (int) [self indexForRow:[self.indexPicker selectedRowInComponent:0]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:YMDHMS fromDate:self.timePicker.date];
    [clockModel setClockId:index];
    [clockModel setSwitchStatus:[self.activeSwitch isOn]];
    [clockModel setClockHour:components.hour];
    [clockModel setClockMinute:components.minute];
    [clockModel setViable:[self.viableSwitch isOn]];
    [clockModel setWeekRepeat:self.repeat];
    
    return clockModel;
}

#pragma PickerView DataSource Delegate

#define MIN_INDEX 0
#define MAX_INDEX 8

- (NSInteger)rowForIndex:(NSInteger)index
{
    return index;
}

- (NSInteger)indexForRow:(NSInteger)row
{
    return row;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.indexPicker]) {
        return MAX_INDEX - MIN_INDEX;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.indexPicker]) {
        return [NSString stringWithFormat:@"%d", (int)[self indexForRow:row]];
    }
    return @"";
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

- (void)addAlarmToHtml:(IwownClock*)alarm
{
    [self addSubtituloToHtml:[NSString stringWithFormat:@"%2lu:%2lu",(unsigned long)alarm.clockHour,alarm.clockMinute]];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:[NSString stringWithFormat:@"%@",alarm]];
    [self.htmlbody appendString:htmlCode];
    [self updateUI];
    
}

- (void)addSubtituloToHtml:(NSString *)titulo
{
    [self.htmlbody appendString:[[NSMutableString alloc] initWithFormat:@"<h4>%@</h4>",titulo]];
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
    NSLog(@"AlarmViewController - webView didFailLoadWithError - error: %@", error);
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
