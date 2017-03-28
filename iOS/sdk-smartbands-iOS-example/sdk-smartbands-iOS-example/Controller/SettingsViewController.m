#import "SettingsViewController.h"
#import "DataManager.h"

@interface SettingsViewController ()

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)updateUI
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma Actions

- (IBAction)reset:(id)sender
{
    [self.dataManager deviceReset];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
