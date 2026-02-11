//
//  ProfileHeaderView.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "ProfileHeaderView.h"
#import "User.h"
#import "Constants.h"
#import "ImageLoader.h"
#import "DataService.h"
#import "LoloWalletDetailView.h"

@interface ProfileHeaderView ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *followingLabel;
@property (nonatomic, strong) UIView *statsCard;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *distanceValueLabel;
@property (nonatomic, strong) UILabel *caloriesLabel;
@property (nonatomic, strong) UILabel *caloriesValueLabel;
@property (nonatomic, strong) UILabel *workoutsLabel;
@property (nonatomic, strong) UILabel *workoutsValueLabel;
@property (nonatomic, strong) UILabel *coinsLabel;
@property (nonatomic, strong) UIButton *buyCoinsButton;
@property (nonatomic, weak) UIViewController *parentViewController;
@end

@implementation ProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [LOLOColors background];
        [self setupUI];
        
        // Listen for coins balance changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCoinsBalance)
                                                     name:@"CoinsBalanceDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    CGFloat padding = [LOLOSpacing medium];
    
    // Avatar
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 60;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.avatarImageView];
    
    // Name
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [LOLOFonts title];
    self.nameLabel.textColor = [LOLOColors textPrimary];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 2; // Allow wrapping for long names
    self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.nameLabel];
    
    // Bio
    self.bioLabel = [[UILabel alloc] init];
    self.bioLabel.font = [LOLOFonts body];
    self.bioLabel.textColor = [LOLOColors textSecondary];
    self.bioLabel.textAlignment = NSTextAlignmentCenter;
    self.bioLabel.numberOfLines = 2;
    self.bioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bioLabel];
    
    // Followers/Following
    UIStackView *followStack = [[UIStackView alloc] init];
    followStack.axis = UILayoutConstraintAxisHorizontal;
    followStack.distribution = UIStackViewDistributionFillEqually;
    followStack.spacing = 40;
    followStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:followStack];
    
    UIView *followersView = [self createStatView:@"" label:@"Followers"];
    UIView *followingView = [self createStatView:@"" label:@"Following"];
    [followStack addArrangedSubview:followersView];
    [followStack addArrangedSubview:followingView];
    
    // Get the value labels (first subview in each stat view)
    for (UIView *subview in followersView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.font.pointSize == 20) { // The value label has size 20
                self.followersLabel = label;
                break;
            }
        }
    }
    
    for (UIView *subview in followingView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.font.pointSize == 20) { // The value label has size 20
                self.followingLabel = label;
                break;
            }
        }
    }
    
    // Coins display and buy button
    UIView *coinsContainer = [[UIView alloc] init];
    coinsContainer.backgroundColor = [UIColor whiteColor];
    coinsContainer.layer.cornerRadius = [LOLOCornerRadius standard];
    coinsContainer.layer.borderColor = [LOLOColors primary].CGColor;
    coinsContainer.layer.borderWidth = 2;
    coinsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:coinsContainer];
    
    self.coinsLabel = [[UILabel alloc] init];
    self.coinsLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.coinsLabel.textColor = [LOLOColors textPrimary];
    self.coinsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [coinsContainer addSubview:self.coinsLabel];
    
    self.buyCoinsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.buyCoinsButton setTitle:@"Buy Coins" forState:UIControlStateNormal];
    self.buyCoinsButton.titleLabel.font = [LOLOFonts bodyBold];
    self.buyCoinsButton.backgroundColor = [LOLOColors primary];
    [self.buyCoinsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.buyCoinsButton.layer.cornerRadius = [LOLOCornerRadius standard];
    self.buyCoinsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buyCoinsButton addTarget:self action:@selector(buyCoinsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [coinsContainer addSubview:self.buyCoinsButton];
    
    [self updateCoinsBalance];
    
    // Stats card
    self.statsCard = [[UIView alloc] init];
    self.statsCard.backgroundColor = [UIColor whiteColor];
    self.statsCard.layer.cornerRadius = [LOLOCornerRadius standard];
    self.statsCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.statsCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.statsCard.layer.shadowOpacity = 0.1;
    self.statsCard.layer.shadowRadius = 8;
    self.statsCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.statsCard];
    
    // Sport Statistics label
    UILabel *statsTitle = [[UILabel alloc] init];
    statsTitle.text = @"";
    statsTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    statsTitle.textColor = [LOLOColors textPrimary];
    statsTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsCard addSubview:statsTitle];
    
    // Stats  icons and values
    UIStackView *statsStack = [[UIStackView alloc] init];
    statsStack.axis = UILayoutConstraintAxisHorizontal;
    statsStack.distribution = UIStackViewDistributionFillEqually;
    statsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statsCard addSubview:statsStack];
    
    UIView *distanceView = [self createStatsItemView:@"🏃" value:@"2847.5 km" label:@"Distance"];
    UIView *caloriesView = [self createStatsItemView:@"🔥" value:@"145230 cal" label:@"Calories"];
    UIView *workoutsView = [self createStatsItemView:@"💪" value:@"386" label:@"Workouts"];
    [statsStack addArrangedSubview:distanceView];
    [statsStack addArrangedSubview:caloriesView];
    [statsStack addArrangedSubview:workoutsView];
    
    self.distanceValueLabel = distanceView.subviews[1];
    self.caloriesValueLabel = caloriesView.subviews[1];
    self.workoutsValueLabel = workoutsView.subviews[1];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.avatarImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:padding],
        [self.avatarImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.avatarImageView.widthAnchor constraintEqualToConstant:120],
        [self.avatarImageView.heightAnchor constraintEqualToConstant:120],
        
        [self.nameLabel.topAnchor constraintEqualToAnchor:self.avatarImageView.bottomAnchor constant:padding],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        [self.nameLabel.heightAnchor constraintGreaterThanOrEqualToConstant:50], // Fixed height to prevent compression
        
        [self.bioLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:4],
        [self.bioLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [self.bioLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        
        [followStack.topAnchor constraintEqualToAnchor:self.bioLabel.bottomAnchor constant:padding],
        [followStack.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [followStack.widthAnchor constraintEqualToConstant:240],
        
        [coinsContainer.topAnchor constraintEqualToAnchor:followStack.bottomAnchor constant:padding],
        [coinsContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding*2],
        [coinsContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding*2],
        [coinsContainer.heightAnchor constraintEqualToConstant:50],
        
        [self.coinsLabel.leadingAnchor constraintEqualToAnchor:coinsContainer.leadingAnchor constant:padding],
        [self.coinsLabel.centerYAnchor constraintEqualToAnchor:coinsContainer.centerYAnchor],
        
        [self.buyCoinsButton.trailingAnchor constraintEqualToAnchor:coinsContainer.trailingAnchor constant:-padding],
        [self.buyCoinsButton.centerYAnchor constraintEqualToAnchor:coinsContainer.centerYAnchor],
        [self.buyCoinsButton.widthAnchor constraintEqualToConstant:100],
        [self.buyCoinsButton.heightAnchor constraintEqualToConstant:36],
        
        [self.statsCard.topAnchor constraintEqualToAnchor:coinsContainer.bottomAnchor constant:padding],
        [self.statsCard.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:padding],
        [self.statsCard.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-padding],
        [self.statsCard.heightAnchor constraintEqualToConstant:120],
        [self.statsCard.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-padding],
        
        [statsTitle.topAnchor constraintEqualToAnchor:self.statsCard.topAnchor constant:padding],
        [statsTitle.leadingAnchor constraintEqualToAnchor:self.statsCard.leadingAnchor constant:padding],
        [statsTitle.trailingAnchor constraintLessThanOrEqualToAnchor:self.statsCard.trailingAnchor constant:-padding],
        
        [statsStack.topAnchor constraintEqualToAnchor:statsTitle.bottomAnchor constant:padding],
        [statsStack.leadingAnchor constraintEqualToAnchor:self.statsCard.leadingAnchor constant:padding],
        [statsStack.trailingAnchor constraintEqualToAnchor:self.statsCard.trailingAnchor constant:-padding],
        [statsStack.bottomAnchor constraintEqualToAnchor:self.statsCard.bottomAnchor constant:-padding],
        [statsStack.heightAnchor constraintEqualToConstant:80],
    ]];
}

- (UIView *)createStatView:(NSString *)value label:(NSString *)label {
    UIView *view = [[UIView alloc] init];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    valueLabel.textColor = [LOLOColors textPrimary];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:valueLabel];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [LOLOFonts body];
    titleLabel.textColor = [LOLOColors textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [valueLabel.topAnchor constraintEqualToAnchor:view.topAnchor],
        [valueLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [valueLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:2],
        [titleLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor],
    ]];
    
    return view;
}

- (UIView *)createStatsItemView:(NSString *)icon value:(NSString *)value label:(NSString *)label {
    UIView *view = [[UIView alloc] init];
    
    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = icon;
    iconLabel.font = [UIFont systemFontOfSize:32];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:iconLabel];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value;
    valueLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    valueLabel.textColor = [LOLOColors primary];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:valueLabel];
    
   UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = label;
    titleLabel.font = [LOLOFonts caption];
    titleLabel.textColor = [LOLOColors textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconLabel.topAnchor constraintEqualToAnchor:view.topAnchor],
        [iconLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [valueLabel.topAnchor constraintEqualToAnchor:iconLabel.bottomAnchor constant:4],
        [valueLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:2],
        [titleLabel.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
    ]];
    
    return view;
}

- (void)configureWithUser:(User *)user {
    self.nameLabel.text = user.username;
    self.bioLabel.text = user.bio;
    self.followersLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followersCount];
    self.followingLabel.text = [NSString stringWithFormat:@"%ld", (long)user.followingCount];
    
    self.distanceValueLabel.text = [NSString stringWithFormat:@"%.1f km", user.totalDistance];
    self.caloriesValueLabel.text = [NSString stringWithFormat:@"%ld cal", (long)user.totalCalories];
    self.workoutsValueLabel.text = [NSString stringWithFormat:@"%ld", (long)user.totalWorkouts];
    
    [self.avatarImageView loadImageFromURLString:user.avatar 
                                      placeholder:@"person.circle.fill" 
                                         username:user.username];
                                         
    // Store parent view controller for presenting coin store
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            self.parentViewController = (UIViewController *)responder;
            break;
        }
        responder = responder.nextResponder;
    }
}

- (void)updateCoinsBalance {
    NSInteger coins = [[DataService shared] getCurrentUserCoins];
    self.coinsLabel.text = [NSString stringWithFormat:@"🪙 %ld coins", (long)coins];
}

- (void)buyCoinsButtonTapped {
    if (self.parentViewController) {
        LoloWalletDetailView *storeVC = [[LoloWalletDetailView alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeVC];
        [self.parentViewController presentViewController:nav animated:YES completion:nil];
    }
}

@end
