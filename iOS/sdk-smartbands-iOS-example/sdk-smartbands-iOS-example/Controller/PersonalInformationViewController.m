#import "PersonalInformationViewController.h"
#import "DataManager.h"

@interface PersonalInformationViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate,UIWebViewDelegate>

@property (strong, nonatomic) DataManager *dataManager;

@property (weak, nonatomic) IBOutlet UIButton *man;
@property (weak, nonatomic) IBOutlet UIButton *woman;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UIPickerView *height;
@property (weak, nonatomic) IBOutlet UIPickerView *weight;
@property (weak, nonatomic) IBOutlet UIPickerView *goal;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;


@end

@implementation PersonalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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
    [self updateGender];
}

- (void)updateGender
{
    if (self.dataManager.man) {
        [self.man setBackgroundColor:[UIColor greenColor]];
        [self.man setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.woman setBackgroundColor:[UIColor whiteColor]];
        [self.woman setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    } else {
        [self.man setBackgroundColor:[UIColor whiteColor]];
        [self.man setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.woman setBackgroundColor:[UIColor greenColor]];
        [self.woman setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma Actions


- (IBAction)setPersonalInformation:(UIButton *)sender {
    int height = (int) [self heightForRow:[self.height selectedRowInComponent:0]];
    int weight = (int) [self weightForRow:[self.weight selectedRowInComponent:0]];
    int goal = (int) [self goalForRow:[self.goal selectedRowInComponent:0]];
    
    IwownPersonal *iwPersonal = [IwownPersonal defaultPersonalModel];
    
    [iwPersonal setGender:self.dataManager.man ? 0 : 1 ];
    [iwPersonal setHeight: height];
    [iwPersonal setWeight: weight];
    [iwPersonal setTarget: goal];
    
    if (![self.ageTF.text isEqualToString:@""]) {
        [iwPersonal setAge:[self.ageTF.text intValue]];
    } else {
        [iwPersonal setAge:20];
    }
    
    [[BLELib3 shareInstance] setPersonalInfo:iwPersonal];
    
    [self addPersonalInformationToHtml:iwPersonal];
}

- (IBAction)selectMan:(UIButton *)sender
{
    self.dataManager.man = YES;
    [self updateGender];
}

- (IBAction)selectWoman:(UIButton *)sender
{
    self.dataManager.man = NO;
    [self updateGender];
}

#pragma PickerView DataSource Delegate

#define MIN_WEIGHT 10
#define MAX_WEIGHT 255

- (NSInteger)rowForWeight:(NSInteger)weight
{
    return weight - MIN_WEIGHT;
}

- (NSInteger)weightForRow:(NSInteger)row
{
    return row + MIN_WEIGHT;
}

#define MIN_HEIGHT 60
#define MAX_HEIGHT 255

- (NSInteger)rowForHeight:(NSInteger)height
{
    return height - MIN_HEIGHT;
}

- (NSInteger)heightForRow:(NSInteger)row
{
    return row + MIN_HEIGHT;
}

#define MIN_GOAL 5000
#define MAX_GOAL 21000

- (NSInteger)rowForGoal:(NSInteger)goal
{
    return goal - MIN_GOAL;
}

- (NSInteger)goalForRow:(NSInteger)row
{
    return (row * 1000) + MIN_GOAL;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.weight]) {
        return MAX_WEIGHT - MIN_WEIGHT;
    }
    if ([pickerView isEqual:self.height]) {
        return MAX_HEIGHT - MIN_HEIGHT;
    }
    if ([pickerView isEqual:self.goal]) {
        return ((MAX_GOAL - MIN_GOAL)/1000);
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.weight]) {
        return [NSString stringWithFormat:@"%li", (long)[self weightForRow:row]];
    }
    if ([pickerView isEqual:self.height]) {
        return [NSString stringWithFormat:@"%li", (long)[self heightForRow:row]];
    }
    if ([pickerView isEqual:self.goal]) {
        return [NSString stringWithFormat:@"%li", (long)[self goalForRow:row]];
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

- (void)addPersonalInformationToHtml:(IwownPersonal *)personInfo
{
    [self addSubtituloToHtml:[NSString stringWithFormat:@"Set Personal Information"]];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    [htmlCode appendString:[NSString stringWithFormat:@"%@",personInfo]];
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
    NSLog(@"PersonalInformationViewController - webView didFailLoadWithError - error: %@", error);
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
