#import "HardwareOptionsViewController.h"
#import "DataManager.h"

@interface HardwareOptionsViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *languageSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitTypeSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeFlagSC;
@property (weak, nonatomic) IBOutlet UISwitch *backgroundColor;
@property (weak, nonatomic) IBOutlet UISwitch *autoSleep;
@property (weak, nonatomic) IBOutlet UITextField *startTime;
@property (weak, nonatomic) IBOutlet UITextField *endTime;
@property (weak, nonatomic) IBOutlet UISwitch *ledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *wristSwitch;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation HardwareOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    [self.languageSC setSelectedSegmentIndex:0];
    [self.unitTypeSC setSelectedSegmentIndex:0];
    [self.timeFlagSC setSelectedSegmentIndex:0];
    
    [self.backgroundColor setOn:YES];
    [self.autoSleep setOn:YES];
    [self.ledSwitch setOn:NO];
    [self.wristSwitch setOn:NO];
    
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

- (IBAction)setOptions:(UIButton *)sender
{
    IwownHWOption *option = [self createOptionObject];
     [[BLELib3 shareInstance] setFirmWareOption:option];
    [self addHWOptionToHtml:option];
}

- (IwownHWOption*)createOptionObject
{
    IwownHWOption *option = [IwownHWOption defaultHWOption];
    
    [option setLanguage:(self.languageSC.selectedSegmentIndex == braceletLanguageEnglish ? braceletLanguageEnglish : braceletLanguageSimpleChinese)];
    [option setUnitType:(self.unitTypeSC.selectedSegmentIndex == UnitTypeInternational ? UnitTypeInternational : UnitTypeEnglish)];
    [option setTimeFlag:self.timeFlagSC.selectedSegmentIndex == TimeFlag24Hour ? TimeFlag24Hour : TimeFlag12Hour];
    
    [option setBackColor:self.backgroundColor.isOn];
    
    [option setAutoSleep:self.autoSleep.isOn];
    if (![self.startTime.text isEqualToString:@""]) {
        [option setBacklightStart:[self.startTime.text intValue]];
    } else {
        [option setBacklightStart:16];
    }
    
    if (![self.endTime.text isEqualToString:@""]) {
        [option setBacklightEnd:[self.endTime.text intValue]];
    } else {
        [option setBacklightEnd:8];
    }
    
    [option setLedSwitch:self.ledSwitch.isOn];
    [option setWristSwitch:self.wristSwitch.isOn];
    
    return option;
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

- (void)addHWOptionToHtml:(IwownHWOption*)hwOption
{
    [self addSubtituloToHtml:@"Set HW Option"];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:[NSString stringWithFormat:@"%@",hwOption]];
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
