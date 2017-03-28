#import "SportsViewController.h"
#import "DataManager.h"

@interface SportsViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (weak, nonatomic) IBOutlet UITextField *sport1;
@property (weak, nonatomic) IBOutlet UITextField *sport2;
@property (weak, nonatomic) IBOutlet UITextField *sport3;
@property (weak, nonatomic) IBOutlet UITextField *sport4;
@property (weak, nonatomic) IBOutlet UITextField *sport5;
@property (strong, nonatomic) NSArray *sportTFArray;

@property (weak, nonatomic) IBOutlet UITextField *goal1;
@property (weak, nonatomic) IBOutlet UITextField *goal2;
@property (weak, nonatomic) IBOutlet UITextField *goal3;
@property (weak, nonatomic) IBOutlet UITextField *goal4;
@property (weak, nonatomic) IBOutlet UITextField *goal5;
@property (strong, nonatomic) NSArray *goalTFArray;


@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation SportsViewController

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
    
    self.sportTFArray = @[self.sport2,self.sport3,self.sport4,self.sport5];
    self.goalTFArray = @[self.goal2,self.goal3,self.goal4,self.goal5];
    
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

- (IBAction)setSports:(UIButton *)sender
{
    NSMutableArray *sportsDay = [self createSportArray];
    [self.dataManager setSportTarget:sportsDay];
    [self addSportsArrayToHtml:sportsDay];
}

- (NSMutableArray *)createSportArray
{
    NSDictionary *walkTarget;
    if (![self.goal1.text isEqualToString:@""]) {
        walkTarget = @{ @"target": self.goal1.text,
                        @"sportType": @"01" };
    } else {
        walkTarget = @{ @"target": @"1000",
                        @"sportType": @"01" };
    }
    
    NSMutableArray *sportsDay = [NSMutableArray arrayWithObject:walkTarget];
    
    UITextField *sport;
    UITextField *target;
    
    for (int i = 0; i < 4; i++) {
        sport = self.sportTFArray[i];
        if (![sport.text isEqualToString:@""]) {
            target = self.goalTFArray[i];
            NSDictionary *sportTarget;
            if (![target.text isEqualToString:@""]) {
                sportTarget = @{ @"target": target.text,
                                 @"sportType": sport.text };
            } else {
                sportTarget = @{ @"target": @"1000",
                                 @"sportType": sport.text };
            }
            [sportsDay addObject:sportTarget];
        }
    }
    return sportsDay;
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

- (void)addSportsArrayToHtml:(NSArray*)sportsDays
{
    [self addSubtituloToHtml:@"SET SPORTS - raw data"];
    [self.htmlbody appendString:[NSString stringWithFormat:@"%@",sportsDays]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
