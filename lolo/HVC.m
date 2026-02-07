//
//  HVC.m (Updated with navigation)
//  lolo
//
//  Created on 2026/2/3.
//

#import "ViewControllers.h"
#import "Constants.h"
#import "Post.h"
#import "User.h"
#import "FeedCardCell.h"
#import "Views/Home/PostDetailViewController.h"
#import "Views/Home/CreatePostViewController.h"
#import "Views/Home/ReportViewController.h"
#import "Views/CoinStoreViewController.h"
#import "ViewModels/HomeViewModel.h"
#import "DataService.h"

@interface HVC () <UITableViewDelegate, UITableViewDataSource, FeedCardCellDelegate>
@property (nonatomic, strong) HomeViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *headerLabel;
@end

@implementation HVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Home";
    self.view.backgroundColor = [LOLOColors background];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    // Add + button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPostTapped)];
    addButton.tintColor = [LOLOColors primary];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Initialize ViewModel
    self.viewModel = [[HomeViewModel alloc] init];
    
    // Setup UI
    [self setupTableView];
    [self setupBindings];
    
    // Load data
    [self.viewModel loadData];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [LOLOColors background];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.estimatedRowHeight = 400;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    headerView.backgroundColor = [LOLOColors background];
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.text = @"Activity Feed";
    self.headerLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.headerLabel.textColor = [LOLOColors textPrimary];
    self.headerLabel.frame = CGRectMake([LOLOSpacing medium], 15, self.view.bounds.size.width - 2*[LOLOSpacing medium], 30);
    [headerView addSubview:self.headerLabel];
    self.tableView.tableHeaderView = headerView;
    
    // Register cell
    [self.tableView registerClass:[FeedCardCell class] forCellReuseIdentifier:@"FeedCardCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)setupBindings {
    __weak typeof(self) weakSelf = self;
    self.viewModel.onDataUpdated = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    };
}

- (void)createPostTapped {
    CreatePostViewController *createVC = [[CreatePostViewController alloc] init];
    createVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:createVC];
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCardCell" forIndexPath:indexPath];
    Post *post = self.viewModel.posts[indexPath.row];
    cell.delegate = self;
    
    // Get current user ID from DataService
    User *currentUser = [[DataService shared] getCurrentUser];
    cell.currentUserId = currentUser.userId;
    
    [cell configureWithPost:post];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = self.viewModel.posts[indexPath.row];
    
    // Debug: Print post info
    NSLog(@"[HVC] Selected post at index %ld: ID=%@, User=%@, Content=%@", 
          (long)indexPath.row, post.postId, post.user.username, 
          [post.content substringToIndex:MIN(30, post.content.length)]);
    
    PostDetailViewController *detailVC = [[PostDetailViewController alloc] initWithPost:post];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Auto-play disabled per user request
    // Videos only play when user explicitly taps play button
    /*
    // Don't pause videos when app is in background
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
   
    // Play video in visible cells
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        FeedCardCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[FeedCardCell class]]) {
            CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
            CGRect visibleRect = CGRectIntersection(cellRect, self.tableView.bounds);
            
            // If more than 70% of cell is visible, play video
            CGFloat visibleHeight = CGRectGetHeight(visibleRect);
            CGFloat cellHeight = CGRectGetHeight(cellRect);
            
            if (visibleHeight / cellHeight > 0.7) {
                [cell playVideo];
            } else {
                [cell pauseVideo];
            }
        }
    }
    */
}

#pragma mark - FeedCardCellDelegate

- (void)feedCardCell:(FeedCardCell *)cell didTapCommentForPost:(Post *)post {
    PostDetailViewController *detailVC = [[PostDetailViewController alloc] initWithPost:post];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)feedCardCell:(FeedCardCell *)cell didTapReportForPost:(Post *)post {
    ReportViewController *reportVC = [[ReportViewController alloc] initWithPost:post];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:reportVC];
    navVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navVC animated:YES completion:nil];
}

#define COINS_FOR_PIN 10
#define PIN_DURATION_HOURS 24

- (void)feedCardCell:(FeedCardCell *)cell didTapPinForPost:(Post *)post {
    NSInteger currentCoins = [[DataService shared] getCurrentUserCoins];
    
    if (currentCoins < COINS_FOR_PIN) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Insufficient Coins"
                                                                       message:[NSString stringWithFormat:@"Pin a post for 24h costs %d coins. You have %ld coins.\n\nBuy more coins?", COINS_FOR_PIN, (long)currentCoins]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Buy Coins" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CoinStoreViewController *storeVC = [[CoinStoreViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeVC];
            [self presentViewController:nav animated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"📌 Pin Post"
                                                                          message:[NSString stringWithFormat:@"Pin to top for 24 hours?\n\nCost: %d coins\nBalance: %ld coins", COINS_FOR_PIN, (long)currentCoins]
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [confirmAlert addAction:[UIAlertAction actionWithTitle:@"Pin 24h" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[DataService shared] deductCoins:COINS_FOR_PIN]) {
            NSTimeInterval duration = PIN_DURATION_HOURS * 3600;
            [[DataService shared] pinPost:post duration:duration];
            [self.viewModel loadData];
            
            UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"✅ Post Pinned!"
                                                                                  message:@"Your post will stay at the top for 24 hours."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:successAlert animated:YES completion:nil];
        }
    }]];
    [self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark - CreatePostViewControllerDelegate

- (void)createPostViewController:(CreatePostViewController *)controller didCreatePost:(Post *)post {
    // Persist the post to DataService
    [[DataService shared] addPost:post];
    
    // Add to view model and reload
    [self.viewModel addNewPost:post];
    [self.tableView reloadData];
    
    // Scroll to top to show new post
    if (self.viewModel.posts.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

@end
