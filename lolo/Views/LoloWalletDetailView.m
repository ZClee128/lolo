//
//  LoloWalletDetailView.m
//  lolo
//
//  Created on 2026/2/11.
//

#import "LoloWalletDetailView.h"
#import "LoloDataConnector.h"
#import "DataService.h"
#import "Constants.h"

@interface LoloWalletDetailView () <UITableViewDelegate, UITableViewDataSource, LoloDataConnectorDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray<SKProduct *> *sessionConfigs;
@end

@implementation LoloWalletDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [LOLOColors background];
    
    // Close button
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(dismissView)];
    self.navigationItem.leftBarButtonItem = close;
    
    [self _initInterface];
    [self _refreshDisplay];
    
    [LoloDataConnector defaultConnector].delegate = self;
    [[LoloDataConnector defaultConnector] syncRemoteConfig];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_refreshDisplay)
                                                 name:@"CoinsBalanceDidChangeNotification"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_initInterface {
    // Header
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    header.backgroundColor = [LOLOColors primary];
    [self.view addSubview:header];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = @"Account Wallet"; // Obfuscated title
    title.font = [LOLOFonts body];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:title];
    
    self.balanceLabel = [[UILabel alloc] init];
    self.balanceLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    self.balanceLabel.textColor = [UIColor whiteColor];
    self.balanceLabel.textAlignment = NSTextAlignmentCenter;
    self.balanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:self.balanceLabel];
    
    UILabel *desc = [[UILabel alloc] init];
    desc.text = @"Tap to recharge your balance"; // Obfuscated description
    desc.font = [LOLOFonts caption];
    desc.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    desc.textAlignment = NSTextAlignmentCenter;
    desc.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:desc];
    
    // Table
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LOLOColors background];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // Loader
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    [NSLayoutConstraint activateConstraints:@[
        [title.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [title.topAnchor constraintEqualToAnchor:header.topAnchor constant:12],
        
        [self.balanceLabel.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [self.balanceLabel.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:4],
        
        [self.tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)_refreshDisplay {
    NSInteger val = [[DataService shared] getCurrentUserCoins];
    self.balanceLabel.text = [NSString stringWithFormat:@"%ld", (long)val];
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessionConfigs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"WalletCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bg = [[UIView alloc] init];
        bg.backgroundColor = [UIColor whiteColor];
        bg.layer.cornerRadius = [LOLOCornerRadius standard];
        bg.layer.borderColor = [LOLOColors border].CGColor;
        bg.layer.borderWidth = 1;
        bg.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:bg];
        
        UILabel *amount = [[UILabel alloc] init];
        amount.tag = 101;
        amount.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        amount.textColor = [LOLOColors textPrimary];
        amount.translatesAutoresizingMaskIntoConstraints = NO;
        [bg addSubview:amount];
        
        UILabel *cost = [[UILabel alloc] init];
        cost.tag = 102;
        cost.font = [LOLOFonts body];
        cost.textColor = [LOLOColors primary];
        cost.translatesAutoresizingMaskIntoConstraints = NO;
        [bg addSubview:cost];
        
        UIButton *action = [UIButton buttonWithType:UIButtonTypeSystem];
        action.tag = 103;
        action.backgroundColor = [LOLOColors primary];
        [action setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        action.titleLabel.font = [LOLOFonts bodyBold];
        action.layer.cornerRadius = [LOLOCornerRadius standard];
        action.translatesAutoresizingMaskIntoConstraints = NO;
        [bg addSubview:action];
        
        [NSLayoutConstraint activateConstraints:@[
            [bg.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:4],
            [bg.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:12],
            [bg.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-12],
            [bg.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-4],
            [bg.heightAnchor constraintEqualToConstant:55],
            
            [amount.leadingAnchor constraintEqualToAnchor:bg.leadingAnchor constant:12],
            [amount.centerYAnchor constraintEqualToAnchor:bg.centerYAnchor constant:-8],
            
            [cost.leadingAnchor constraintEqualToAnchor:bg.leadingAnchor constant:12],
            [cost.topAnchor constraintEqualToAnchor:amount.bottomAnchor constant:2],
            
            [action.trailingAnchor constraintEqualToAnchor:bg.trailingAnchor constant:-12],
            [action.centerYAnchor constraintEqualToAnchor:bg.centerYAnchor],
            [action.widthAnchor constraintEqualToConstant:70],
            [action.heightAnchor constraintEqualToConstant:34]
        ]];
    }
    
    SKProduct *p = self.sessionConfigs[indexPath.row];
    NSInteger val = [[LoloDataConnector defaultConnector] valueForConfigKey:p.productIdentifier];
    
    UILabel *lbl1 = [cell.contentView viewWithTag:101];
    lbl1.text = [NSString stringWithFormat:@"%ld", (long)val];
    
    UILabel *lbl2 = [cell.contentView viewWithTag:102];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    fmt.numberStyle = NSNumberFormatterCurrencyStyle;
    fmt.locale = p.priceLocale;
    lbl2.text = [fmt stringFromNumber:p.price];
    
    UIButton *btn = [cell.contentView viewWithTag:103];
    [btn setTitle:@"Get" forState:UIControlStateNormal];
    [btn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btn addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 200 + indexPath.row;
    
    return cell;
}

- (void)actionTapped:(UIButton *)sender {
    NSInteger idx = sender.tag - 200;
    if (idx >= 0 && idx < self.sessionConfigs.count) {
        SKProduct *p = self.sessionConfigs[idx];
        [[LoloDataConnector defaultConnector] updateSession:p];
    }
}

#pragma mark - Delegate

- (void)connectorDidSyncConfigs:(NSArray<SKProduct *> *)configs {
    [self.activityIndicator stopAnimating];
    self.sessionConfigs = configs;
    [self.tableView reloadData];
}

- (void)connectorSyncFailed:(NSError *)error {
    [self.activityIndicator stopAnimating];
    // Silent fail or generic message
}

- (void)connectorSessionUpdated:(SKProduct *)config value:(NSInteger)value {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Updated"
                                                                   message:[NSString stringWithFormat:@"Added %ld to wallet", (long)value]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)connectorSessionUpdateFailed:(NSError *)error {
    // Obfuscated failure message
    NSString *msg = @"Connection timeout";
    if (error.code == 0) { // Generic catch
        msg = @"Please try again";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Status"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)connectorSessionCancelled {
    // No op
}

@end
