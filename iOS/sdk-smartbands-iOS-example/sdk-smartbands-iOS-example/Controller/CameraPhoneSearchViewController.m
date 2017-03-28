#import "CameraPhoneSearchViewController.h"
#import "DataManager.h"

@interface CameraPhoneSearchViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *keyNotify;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *htmlHeader;
@property (strong, nonatomic) NSString *htmlEnd;
@property (strong, nonatomic) NSMutableString *htmlbody;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation CameraPhoneSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    
    [self.keyNotify setOn:YES];
    
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    self.baseURL = [NSURL fileURLWithPath:path];
    self.htmlbody = [[NSMutableString alloc] initWithString:@""];
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

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(takePictureNotify:)
                   name:@"TakePictureNotify"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(searchPhoneNotify:)
                   name:@"SearchPhoneNotify"
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma Notification selector

- (void)takePictureNotify:(NSNotification *)notification
{
    NSLog(@"KeyNotifyViewController - takePictureNotify: %@", notification);
    if (notification.userInfo) {
        NSString *notifyType = [notification.userInfo objectForKey:@"type"];
        if (notifyType) {
            [self addSubtituloToHtml:[NSString stringWithFormat:@"Received: %@",notifyType]];
            [self updateUI];
        }
    }
}

- (void)searchPhoneNotify:(NSNotification *)notification
{
    NSLog(@"KeyNotifyViewController - searchPhoneNotify: %@", notification);
    if (notification.userInfo) {
        NSString *notifyType = [notification.userInfo objectForKey:@"type"];
        if (notifyType) {
            [self addSubtituloToHtml:[NSString stringWithFormat:@"Received: %@",notifyType]];
            [self updateUI];
        }
    }
}

#pragma Actions

- (IBAction)sendKeyNotifyToDevice:(UIButton *)sender
{
    [[BLELib3 shareInstance] setKeyNotify:self.keyNotify.isOn];
    [self addSubtituloToHtml:[NSString stringWithFormat:@"Set KeyNotify - key: %d",self.keyNotify.isOn]];
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

- (void)addNotifyToHtml
{
    [self addSubtituloToHtml:@"Set KeyNotify"];
    NSMutableString *htmlCode = [[NSMutableString alloc] init];
    //    [htmlCode appendString:[NSString stringWithFormat:@"%@",hwOption]];
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
