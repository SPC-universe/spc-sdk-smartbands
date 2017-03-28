#import "DevicesViewController.h"
#import "DataManager.h"

@interface DevicesViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic) NSMutableArray *deviceArray;
@property (strong, nonatomic) DataManager *dataManager;
//@property (strong, nonatomic) TrainingManager *trainingManager;

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.dataManager = [DataManager sharedInstance];
    [self.tableView addSubview:self.activityIndicator];
    self.deviceArray = [[NSMutableArray alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self.dataManager
                                   selector:@selector(scanDevice)
                                   userInfo:nil
                                    repeats:NO];
    [self showActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
    //[self.dataManager stopScan];
}

#pragma Notifications

- (void)setupNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(deviceFoundNotification:)
                   name:@"DeviceFoundNotification"
                 object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceFoundNotification:(NSNotification *)notification {
    NSLog(@"DevicesViewController - deviceFoundNotification: %@", notification);
    [self hideActivityIndicator];
    [self.deviceArray removeAllObjects];
    [self.deviceArray addObjectsFromArray:[self.dataManager getDevices]];
    [self.tableView reloadData];
}

#pragma Activity Indicator

- (void) showActivityIndicator {
    // Center
    CGFloat x = UIScreen.mainScreen.applicationFrame.size.width/2;
    CGFloat y = UIScreen.mainScreen.applicationFrame.size.height/2;
    // Offset. If tableView has been scrolled
    CGFloat yOffset = self.tableView.contentOffset.y;
    self.activityIndicator.frame = CGRectMake(x, y + yOffset, 0, 0);
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void) hideActivityIndicator {
    [self.activityIndicator stopAnimating];
}

#pragma mark - Actions
- (IBAction)refresh:(id)sender {
    [self.dataManager scanDevice];
    [self showActivityIndicator];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    IwownBlePeripheral *device = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = device.deviceName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IwownBlePeripheral *device = [self.deviceArray objectAtIndex:indexPath.row];
    self.dataManager.selectedDevice = device;
    [self.navigationController popViewControllerAnimated:YES];
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
