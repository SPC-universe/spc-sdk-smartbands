#import "SedentaryViewController.h"
#import "DataManager.h"

@interface SedentaryViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *repeatTF;

@property (weak, nonatomic) IBOutlet UIPickerView *startTime;

@property (weak, nonatomic) IBOutlet UIPickerView *endTime;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISwitch *switchStatus;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation SedentaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    [self.switchStatus setOn:YES];
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

- (IBAction)setSedentary:(UIButton *)sender
{
    IwownSedentary *sedentaryModel = [self createSedentaryObject];
    [[BLELib3 shareInstance] setAlertMotionReminder:sedentaryModel];
    [self addSedentaryToHtml:sedentaryModel];
}

- (IwownSedentary*)createSedentaryObject
{
    IwownSedentary *sedentaryModel = [IwownSedentary defaultSedentary];
    
    
    [sedentaryModel setStartHour:[self.startTime selectedRowInComponent:0]];
    [sedentaryModel setEndHour:[self.endTime selectedRowInComponent:0]];
    if (![self.repeatTF.text isEqualToString:@""]) {
        [sedentaryModel setWeekRepeat:[self.repeatTF.text integerValue]];
    } else {
        [sedentaryModel setWeekRepeat:0xff];
    }
    
    [sedentaryModel setSwitchStatus:self.switchStatus.isOn];

    return sedentaryModel;
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

- (void)addSedentaryToHtml:(IwownSedentary*)sedentary
{
    [self addSubtituloToHtml:@"Set Alert Motion Reminder"];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:[NSString stringWithFormat:@"%@",sedentary]];
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
    NSLog(@"SedentaryViewController - webView didFailLoadWithError - error: %@", error);
}

#pragma PickerView DataSource Delegate

#define MIN_HOUR 00
#define MAX_HOUR 24

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.startTime] || [pickerView isEqual:self.endTime]) {
        return MAX_HOUR - MIN_HOUR;
    }

    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.startTime] || [pickerView isEqual:self.endTime]) {
        return [NSString stringWithFormat:@"%02ld",(long)row];
    }
    
    return @"";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
