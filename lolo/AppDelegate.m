//
//  AppDelegate.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "DebugLogger.h"
#import "Views/TermsViewController.h"
#import "Views/TermsAgreementViewController.h"
#import "Utils/StoreManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Create window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[MainTabBarController alloc] init];
    [self.window makeKeyAndVisible];
    
    // Configure Audio Session for background playback
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                             mode:AVAudioSessionModeMoviePlayback
                                          options:AVAudioSessionCategoryOptionMixWithOthers
                                            error:&error];
    if (error) {
        DLog(@"Failed to set audio session category: %@", error);
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        DLog(@"Failed to activate audio session: %@", error);
    }
    
    // Observe account deletion notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAccountDeleted:)
                                                 name:@"AccountDeletedNotification"
                                               object:nil];
    
    // Initialize StoreKit for in-app purchases
    [[StoreManager shared] startStoreKit];
    DLog(@"StoreKit initialized");
    
    // Check if user has accepted terms
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAndShowTermsIfNeeded];
    });
    
    return YES;
}

- (void)handleAccountDeleted:(NSNotification *)notification {
    // Reset to main tab bar first
    self.window.rootViewController = [[MainTabBarController alloc] init];
    
    // Then show terms agreement
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAndShowTermsIfNeeded];
    });
}

- (void)checkAndShowTermsIfNeeded {
    BOOL hasAccepted = [[NSUserDefaults standardUserDefaults] boolForKey:@"HasAgreedToTerms"];
    
    if (!hasAccepted) {
        TermsAgreementViewController *termsVC = [[TermsAgreementViewController alloc] init];
        termsVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        UIViewController *rootVC = self.window.rootViewController;
        if (rootVC) {
            [rootVC presentViewController:termsVC animated:YES completion:nil];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
