//
//  CreatePostViewController.m
//  lolo
//
//  Created on 2026/2/3.
//

#import "CreatePostViewController.h"
#import "Constants.h"
#import "DebugLogger.h"
#import "Post.h"
#import "User.h" 
#import "DataService.h"
#import "LoloWalletDetailView.h"
#import <PhotosUI/PhotosUI.h>
#import "StringObfuscation.h"

#define COINS_PER_POST 0  // Posting is now FREE - coins used for other features

@interface CreatePostViewController () <UITextViewDelegate, PHPickerViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UISegmentedControl *sportTypeControl;
@property (nonatomic, strong) UITextView *experienceTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *distanceField;
@property (nonatomic, strong) UITextField *durationField;
@property (nonatomic, strong) UITextField *caloriesField;
@property (nonatomic, strong) NSArray<NSString *> *sportTypes;
@property (nonatomic, strong) UIButton *addMediaButton;
@property (nonatomic, strong) UIImageView *mediaPreviewImageView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UILabel *coinsLabel;
@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Post";
    self.view.backgroundColor = [LOLOColors background];
    
    // Sport types for segmented control
    self.sportTypes = @[@"Running", @"Cycling", @"Swimming"];
    
    // Navigation buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(cancelTapped)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(postTapped)];
    self.navigationItem.rightBarButtonItem = postButton;
    
    // Coins label in navigation bar
    self.coinsLabel = [[UILabel alloc] init];
    self.coinsLabel.font = [LOLOFonts caption];
    self.coinsLabel.textColor = [LOLOColors textPrimary];
    [self updateCoinsLabel];
    self.navigationItem.titleView = self.coinsLabel;
    
    [self setupUI];
    
    // Listen for coins balance changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCoinsLabel)
                                                 name:[StringObfuscation notificationNameCoinsBalanceChanged]
                                               object:nil];
    
    // Keyboard observation
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

- (void)setupUI {
    CGFloat padding = [LOLOSpacing medium];
    
    // Scroll view
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    // Sport Type Label
    UILabel *sportTypeLabel = [[UILabel alloc] init];
    sportTypeLabel.text = @"Sport Type";
    sportTypeLabel.font = [LOLOFonts bodyBold];
    sportTypeLabel.textColor = [LOLOColors textPrimary];
    sportTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:sportTypeLabel];
    
    // Segmented Control
    self.sportTypeControl = [[UISegmentedControl alloc] initWithItems:self.sportTypes];
    self.sportTypeControl.selectedSegmentIndex = 0;
    self.sportTypeControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.sportTypeControl];
    
    // Experience Label
    UILabel *experienceLabel = [[UILabel alloc] init];
    experienceLabel.text = @"Share your experience";
    experienceLabel.font = [LOLOFonts bodyBold];
    experienceLabel.textColor = [LOLOColors textPrimary];
    experienceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:experienceLabel];
    
    // Experience TextView
    self.experienceTextView = [[UITextView alloc] init];
    self.experienceTextView.font = [LOLOFonts body];
    self.experienceTextView.textColor = [LOLOColors textPrimary];
    self.experienceTextView.backgroundColor = [UIColor whiteColor];
    self.experienceTextView.layer.cornerRadius = [LOLOCornerRadius standard];
    self.experienceTextView.layer.borderColor = [LOLOColors border].CGColor;
    self.experienceTextView.layer.borderWidth = 1;
    self.experienceTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    self.experienceTextView.delegate = self;
    self.experienceTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.experienceTextView];
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = @"Share your experience...";
    self.placeholderLabel.font = [LOLOFonts body];
    self.placeholderLabel.textColor = [LOLOColors textSecondary];
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.experienceTextView addSubview:self.placeholderLabel];
    
    // Add Media Button
    self.addMediaButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addMediaButton setTitle:@"📷 Add Photo or Video" forState:UIControlStateNormal];
    self.addMediaButton.titleLabel.font = [LOLOFonts bodyBold];
    self.addMediaButton.backgroundColor = [LOLOColors primary];
    [self.addMediaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addMediaButton.layer.cornerRadius = [LOLOCornerRadius standard];
    self.addMediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addMediaButton addTarget:self action:@selector(addMediaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addMediaButton];
    
    // Media Preview Image View
    self.mediaPreviewImageView = [[UIImageView alloc] init];
    self.mediaPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaPreviewImageView.clipsToBounds = YES;
    self.mediaPreviewImageView.layer.cornerRadius = [LOLOCornerRadius standard];
    self.mediaPreviewImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.mediaPreviewImageView.hidden = YES;
    self.mediaPreviewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.mediaPreviewImageView];
    
    // Stats Label
    UILabel *statsLabel = [[UILabel alloc] init];
    statsLabel.text = @"Stats (Optional)";
    statsLabel.font = [LOLOFonts bodyBold];
    statsLabel.textColor = [LOLOColors textPrimary];
    statsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:statsLabel];
    
    // Distance Field
    self.distanceField = [self createTextField:@"Distance (km)"];
    self.distanceField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.contentView addSubview:self.distanceField];
    
    // Duration Field
    self.durationField = [self createTextField:@"Duration (min)"];
    self.durationField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:self.durationField];
    
    // Calories Field
    self.caloriesField = [self createTextField:@"Calories"];
    self.caloriesField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:self.caloriesField];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        [sportTypeLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [sportTypeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.sportTypeControl.topAnchor constraintEqualToAnchor:sportTypeLabel.bottomAnchor constant:12],
        [self.sportTypeControl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.sportTypeControl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        
        [experienceLabel.topAnchor constraintEqualToAnchor:self.sportTypeControl.bottomAnchor constant:padding*1.5],
        [experienceLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.experienceTextView.topAnchor constraintEqualToAnchor:experienceLabel.bottomAnchor constant:12],
        [self.experienceTextView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.experienceTextView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.experienceTextView.heightAnchor constraintEqualToConstant:160],
        
        [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.experienceTextView.topAnchor constant:12],
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.experienceTextView.leadingAnchor constant:16],
        
        [self.addMediaButton.topAnchor constraintEqualToAnchor:self.experienceTextView.bottomAnchor constant:padding],
        [self.addMediaButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.addMediaButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.addMediaButton.heightAnchor constraintEqualToConstant:50],
        
        [self.mediaPreviewImageView.topAnchor constraintEqualToAnchor:self.addMediaButton.bottomAnchor constant:padding],
        [self.mediaPreviewImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.mediaPreviewImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.mediaPreviewImageView.heightAnchor constraintEqualToConstant:200],
        
        [statsLabel.topAnchor constraintEqualToAnchor:self.mediaPreviewImageView.bottomAnchor constant:padding*1.5],
        [statsLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        
        [self.distanceField.topAnchor constraintEqualToAnchor:statsLabel.bottomAnchor constant:12],
        [self.distanceField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.distanceField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.distanceField.heightAnchor constraintEqualToConstant:50],
        
        [self.durationField.topAnchor constraintEqualToAnchor:self.distanceField.bottomAnchor constant:12],
        [self.durationField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.durationField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.durationField.heightAnchor constraintEqualToConstant:50],
        
        [self.caloriesField.topAnchor constraintEqualToAnchor:self.durationField.bottomAnchor constant:12],
        [self.caloriesField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.caloriesField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.caloriesField.heightAnchor constraintEqualToConstant:50],
        [self.caloriesField.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding*2],
    ]];
}

- (UITextField *)createTextField:(NSString *)placeholder {
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = placeholder;
    textField.font = [LOLOFonts body];
    textField.textColor = [LOLOColors textPrimary];
    textField.backgroundColor = [UIColor whiteColor];
    textField.layer.cornerRadius = [LOLOCornerRadius standard];
    textField.layer.borderColor = [LOLOColors border].CGColor;
    textField.layer.borderWidth = 1;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    return textField;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Media Picker

- (void)addMediaButtonTapped {
    PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
    
    // Support both images and videos
    NSMutableArray *filters = [NSMutableArray array];
    [filters addObject:[PHPickerFilter imagesFilter]];
    [filters addObject:[PHPickerFilter videosFilter]];
    config.filter = [PHPickerFilter anyFilterMatchingSubfilters:filters];
    
    config.selectionLimit = 1;
    config.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeCurrent;
    
    PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (results.count == 0) {
        return; // User cancelled
    }
    
    PHPickerResult *result = results.firstObject;
    
    // Load image
    if ([result.itemProvider canLoadObjectOfClass:[UIImage class]]) {
        [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading> _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)object;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.selectedImage = image;
                    self.mediaPreviewImageView.image = image;
                    self.mediaPreviewImageView.hidden = NO;
                    [self.addMediaButton setTitle:@"✓ Media Added (Tap to change)" forState:UIControlStateNormal];
                });
            }
        }];
    }
}

#pragma mark - Actions

- (void)updateCoinsLabel {
    NSInteger coins = [[DataService shared] getCurrentUserCoins];
    self.coinsLabel.text = [NSString stringWithFormat:@"🪙 %ld coins", (long)coins];
}

- (void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postTapped {
    // Posting is now FREE - no coin check required
    /*
    if (![[DataService shared] hasEnoughCoins:COINS_PER_POST]) {
        [self showInsufficientCoinsAlert];
        return;
    }
    */
    
    // Validate and create post
    NSString *content = self.experienceTextView.text;
    if (content.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" 
                                                                       message:@"Please share your experience" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *sportType = self.sportTypes[self.sportTypeControl.selectedSegmentIndex];
    
    // Get current user
    User *currentUser = [[DataService shared] getCurrentUser];
    
    // Parse stats
    NSNumber *distance = self.distanceField.text.length > 0 ? @([self.distanceField.text doubleValue]) : @0;
    NSNumber *duration = self.durationField.text.length > 0 ? @([self.durationField.text integerValue]) : @0;
    NSNumber *calories = self.caloriesField.text.length > 0 ? @([self.caloriesField.text integerValue]) : @0;
    
    // Save image to disk if user uploaded one
    NSString *savedImagePath = nil;
    if (self.selectedImage) {
        savedImagePath = [self saveImageToDisk:self.selectedImage];
    }
    
    // Create new post
    Post *newPost = [[Post alloc] initWithId:[[NSUUID UUID] UUIDString]
                                        user:currentUser
                                   sportType:sportType
                                     content:content
                                      images:savedImagePath ? @[savedImagePath] : @[@"placeholder.jpg" /* Using local asset instead of external URL */]
                                    videoUrl:nil
                                    distance:distance
                                    duration:duration
                                    calories:calories
                                  likesCount:0
                               commentsCount:0
                                   timestamp:[NSDate date]
                                    location:@"My Location"];
    
    // Store the actual uploaded image in memory for immediate display
    if (self.selectedImage) {
        newPost.selectedImage = self.selectedImage;
    }
    
    // Deduct coins for posting
    BOOL success = [[DataService shared] deductCoins:COINS_PER_POST];
    if (!success) {
        // This shouldn't happen as we checked beforehand, but just in case
        DLog(@"Failed to deduct coins!");
    }
    
    DLog(@"Created post: %@, Sport: %@. Deducted %d coins.", content, sportType, COINS_PER_POST);
    
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(createPostViewController:didCreatePost:)]) {
        [self.delegate createPostViewController:self didCreatePost:newPost];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)saveImageToDisk:(UIImage *)image {
    // Get Documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    // Create unique filename
    NSString *filename = [NSString stringWithFormat:@"post_image_%@.jpg", [[NSUUID UUID] UUIDString]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    // Convert to JPEG data and save
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    
    if (success) {
        DLog(@"Successfully saved image to: %@", filePath);
        // Return ONLY the filename, not the full path
        return filename;
    } else {
        DLog(@"Failed to save image");
        return nil;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showInsufficientCoinsAlert {
    NSInteger currentCoins = [[DataService shared] getCurrentUserCoins];
    NSString *message = [NSString stringWithFormat:@"You need %d coins to post, but you only have %ld coins. Would you like to buy more coins?", COINS_PER_POST, (long)currentCoins];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Insufficient Coins"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Buy Coins" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LoloWalletDetailView *storeVC = [[LoloWalletDetailView alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:storeVC];
        [self presentViewController:nav animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
