#import "ScheduleViewController.h"
#import "DataManager.h"

@interface ScheduleViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextField *subTitleTF;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation ScheduleViewController

const int MAX_TITLE_LENGHT = 20;
const int MAX_DETAIL_LENGHT = 33;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    [self.datePicker setDate:[NSDate date] ];
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

- (IBAction)setSchedule:(UIButton *)sender
{
    if (!([self.titleTF.text isEqualToString:@""] || [self.subTitleTF.text isEqualToString:@""]))  {
        IwownSchedule *scheduleModel = [self createScheduleObject];
        [[BLELib3 shareInstance] writeSchedule:scheduleModel];
        [self addSubtituloToHtml:@"*** WRITE SCHEDULE ***"];
        [self addScheduleToHtml:scheduleModel];
    }
}

- (IBAction)closeSchedule:(UIButton *)sender
{
    IwownSchedule *scheduleModel = [self createScheduleObject];
    [[BLELib3 shareInstance] closeSchedule:scheduleModel];
    [self addSubtituloToHtml:@"*** CLOSE SCHEDULE ***"];
    [self addScheduleToHtml:scheduleModel];
}

- (IBAction)readSchedule:(UIButton *)sender
{
    if (!([self.titleTF.text isEqualToString:@""] || [self.subTitleTF.text isEqualToString:@""]))  {
        IwownSchedule *scheduleModel = [self createScheduleObject];
        [[BLELib3 shareInstance] readSchedule:scheduleModel];
        [self addSubtituloToHtml:@"*** READ SCHEDULE ***"];
        [self addScheduleToHtml:scheduleModel];
    }
}

- (IBAction)clearAllSchedules:(UIButton *)sender
{
    [[BLELib3 shareInstance] clearAllSchedule];
    [self addSubtituloToHtml:@"*** CLEAR ALL SCHEDULES ***"];
    [self updateUI];
}

- (IBAction)readScheduleInfo:(UIButton *)sender
{
    [[BLELib3 shareInstance] readScheduleInfo];
    [self addSubtituloToHtml:@"*** READ SCHEDULE INFO ***"];
    [self updateUI];
}

- (IwownSchedule *)createScheduleObject
{
    IwownSchedule *scheduleModel = [[IwownSchedule alloc] init];
    NSDateComponents *componentsDate = [[NSCalendar currentCalendar] components:YMDHMS fromDate:self.datePicker.date];
    
    scheduleModel.year = componentsDate.year;
    scheduleModel.month = componentsDate.month;
    scheduleModel.day = componentsDate.day;
    scheduleModel.hour = componentsDate.hour;
    scheduleModel.minute = componentsDate.minute;
    scheduleModel.title = self.titleTF.text;
    scheduleModel.subTitle = self.subTitleTF.text;
    
    return scheduleModel;
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

- (void)addScheduleToHtml:(IwownSchedule*)schedule
{
    [self addSubtituloToHtml:[NSString stringWithFormat:@"%2lu/%02lu/%02lu %2lu:%2lu",schedule.year,schedule.month,schedule.day,schedule.hour,schedule.minute]];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:[NSString stringWithFormat:@"%@",schedule]];
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
    NSLog(@"ScheduleViewController - webView didFailLoadWithError - error: %@", error);
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if ([textField isEqual:self.titleTF]) {
        return newLength <= MAX_TITLE_LENGHT;
    } else {
        return newLength <= MAX_DETAIL_LENGHT;
    }
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
