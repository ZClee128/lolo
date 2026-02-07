//
//  CoinStoreViewController.m
//  lolo
//
//  Created on 2026/2/6.
//

#import "CoinStoreViewController.h"
#import "StoreManager.h"
#import "DataService.h"
#import "Constants.h"
#import <StoreKit/StoreKit.h>

@interface CoinStoreViewController () <UITableViewDelegate, UITableViewDataSource, StoreManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *balanceLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) UIBarButtonItem *restoreButton;
@end

@implementation CoinStoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"Buy Coins";
    self.view.backgroundColor = [LOLOColors background];
    
    // Close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeTapped)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    // Restore button
//    self.restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
//                                                          style:UIBarButtonItemStylePlain
//                                                         target:self
//                                                         action:@selector(restoreTapped)];
//    self.navigationItem.rightBarButtonItem = self.restoreButton;
    
    [self setupUI];
    [self updateBalance];
    
    // Set delegate and load products
    [StoreManager shared].delegate = self;
    [[StoreManager shared] loadProducts];
    
    // Listen for coins balance changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBalance)
                                                 name:@"CoinsBalanceDidChangeNotification"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    // Header view with balance
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    headerView.backgroundColor = [LOLOColors primary];
    [self.view addSubview:headerView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Your Balance";
    titleLabel.font = [LOLOFonts body];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    
    self.balanceLabel = [[UILabel alloc] init];
    self.balanceLabel.text = @"0 coins";
    self.balanceLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    self.balanceLabel.textColor = [UIColor whiteColor];
    self.balanceLabel.textAlignment = NSTextAlignmentCenter;
    self.balanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:self.balanceLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"         Use coins to unlock premium features";
    descriptionLabel.font = [LOLOFonts caption];
    descriptionLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:descriptionLabel];
    
    // Table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LOLOColors background];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // Loading indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:12],
        
        [self.balanceLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [self.balanceLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
        
        [self.tableView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)updateBalance {
    NSInteger coins = [[DataService shared] getCurrentUserCoins];
    self.balanceLabel.text = [NSString stringWithFormat:@"🪙 %ld coins", (long)coins];
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restoreTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restore Purchases"
                                                                   message:@"Are you sure you want to restore previous purchases?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[StoreManager shared] restorePurchases];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CoinCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Custom UI
        UIView *containerView = [[UIView alloc] init];
        containerView.tag = 100;
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = [LOLOCornerRadius standard];
        containerView.layer.borderColor = [LOLOColors border].CGColor;
        containerView.layer.borderWidth = 1;
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:containerView];
        
        UILabel *coinLabel = [[UILabel alloc] init];
        coinLabel.tag = 101;
        coinLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        coinLabel.textColor = [LOLOColors textPrimary];
        coinLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:coinLabel];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.tag = 102;
        priceLabel.font = [LOLOFonts body];
        priceLabel.textColor = [LOLOColors primary];
        priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:priceLabel];
        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        buyButton.tag = 103;
        buyButton.backgroundColor = [LOLOColors primary];
        [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buyButton.titleLabel.font = [LOLOFonts bodyBold];
        buyButton.layer.cornerRadius = [LOLOCornerRadius standard];
        buyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:buyButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:4],
            [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:12],
            [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-12],
            [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-4],
            [containerView.heightAnchor constraintEqualToConstant:55],
            
            [coinLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:12],
            [coinLabel.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor constant:-8],
            
            [priceLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:12],
            [priceLabel.topAnchor constraintEqualToAnchor:coinLabel.bottomAnchor constant:2],
            
            [buyButton.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-12],
            [buyButton.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],
            [buyButton.widthAnchor constraintEqualToConstant:70],
            [buyButton.heightAnchor constraintEqualToConstant:34]
        ]];
    }
    
    SKProduct *product = self.products[indexPath.row];
    NSInteger coins = [[StoreManager shared] coinsForProductId:product.productIdentifier];
    
    UILabel *coinLabel = [cell.contentView viewWithTag:101];
    coinLabel.text = [NSString stringWithFormat:@"%ld coins", (long)coins];
    
    UILabel *priceLabel = [cell.contentView viewWithTag:102];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = product.priceLocale;
    priceLabel.text = [formatter stringFromNumber:product.price];
    
    UIButton *buyButton = [cell.contentView viewWithTag:103];
    [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
    [buyButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    buyButton.tag = 200 + indexPath.row; // Store index in tag
    
    return cell;
}

- (void)buyButtonTapped:(UIButton *)sender {
    NSInteger index = sender.tag - 200;
    if (index >= 0 && index < self.products.count) {
        SKProduct *product = self.products[index];
        [[StoreManager shared] purchaseProduct:product];
    }
}

#pragma mark - StoreManagerDelegate

- (void)storeManagerProductsLoaded:(NSArray<SKProduct *> *)products {
    [self.loadingIndicator stopAnimating];
    self.products = products;
    [self.tableView reloadData];
    NSLog(@"[CoinStore] Loaded %lu products", (unsigned long)products.count);
}

- (void)storeManagerProductsLoadFailed:(NSError *)error {
    [self.loadingIndicator stopAnimating];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Failed to load products. Please try again later."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)storeManagerPurchaseSuccess:(SKProduct *)product coins:(NSInteger)coins {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🎉 Success!"
                                                                   message:[NSString stringWithFormat:@"You received %ld coins!", (long)coins]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)storeManagerPurchaseFailed:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Purchase Failed"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)storeManagerPurchaseCancelled {
    // No alert needed for cancellation
    NSLog(@"[CoinStore] Purchase cancelled by user");
}

- (void)storeManagerRestoreCompleted:(NSInteger)restoredCount {
    NSString *message = restoredCount > 0 
        ? [NSString stringWithFormat:@"Restored %ld purchase(s)", (long)restoredCount]
        : @"No purchases to restore";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restore Complete"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)storeManagerRestoreFailed:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restore Failed"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
