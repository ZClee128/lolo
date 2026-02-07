//
//  MainTabBarController.m
//  lolo
//
//  Created on 2026/1/30.
//

#import "MainTabBarController.h"
#import "ObfuscationUtil.h"
#import "Constants.h"
#import "ViewControllers.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTabs];
    [self customizeAppearance];
}

- (void)setupTabs {
    // Home Tab
    HVC *homeVC = [[HVC alloc] init];
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[ObfuscationUtil decodeBytes:@[@0x08, @0x20, @0x21, @0x2A]] // "Home"
                                                       image:[UIImage systemImageNamed:@"house"]
                                                selectedImage:[UIImage systemImageNamed:@"house.fill"]];
    
    // IM Tab
    MVC *imVC = [[MVC alloc] init];
    UINavigationController *imNav = [[UINavigationController alloc] initWithRootViewController:imVC];
    imNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[ObfuscationUtil decodeBytes:@[@0x0D, @0x2A, @0x3F, @0x3C, @0x2D, @0x28, @0x29, @0x3C]] // "Messages"
                                                     image:[UIImage systemImageNamed:@"message"]
                                              selectedImage:[UIImage systemImageNamed:@"message.fill"]];
    
    // Profile Tab
    PVC *profileVC = [[PVC alloc] init];
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:[ObfuscationUtil decodeBytes:@[@0x1C, @0x3D, @0x23, @0x29, @0x25, @0x23, @0x29]] // "Profile"
                                                          image:[UIImage systemImageNamed:@"person"]
                                                   selectedImage:[UIImage systemImageNamed:@"person.fill"]];
    
    self.viewControllers = @[homeNav, imNav, profileNav];
}

- (void)customizeAppearance {
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    
    // Customize selected item color
    appearance.stackedLayoutAppearance.selected.iconColor = [LOLOColors primary];
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
        NSForegroundColorAttributeName: [LOLOColors primary]
    };
    
    // Customize normal item color
    appearance.stackedLayoutAppearance.normal.iconColor = [LOLOColors textSecondary];
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
        NSForegroundColorAttributeName: [LOLOColors textSecondary]
    };
    
    self.tabBar.standardAppearance = appearance;
    
    // scrollEdgeAppearance is only available in iOS 15+
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    
    // Add subtle shadow
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOpacity = 0.1;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -2);
    self.tabBar.layer.shadowRadius = 8;
}

@end
