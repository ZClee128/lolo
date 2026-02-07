//
//  StoreManager.h
//  lolo
//
//  Created on 2026/2/6.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

// Product IDs
extern NSString * const kProductIdLolo;
extern NSString * const kProductIdLolo1;
extern NSString * const kProductIdLolo2;
extern NSString * const kProductIdLolo4;
extern NSString * const kProductIdLolo5;
extern NSString * const kProductIdLolo9;
extern NSString * const kProductIdLolo19;
extern NSString * const kProductIdLolo49;
extern NSString * const kProductIdLolo99;

@protocol StoreManagerDelegate <NSObject>
@optional
- (void)storeManagerProductsLoaded:(NSArray<SKProduct *> *)products;
- (void)storeManagerProductsLoadFailed:(NSError *)error;
- (void)storeManagerPurchaseSuccess:(SKProduct *)product coins:(NSInteger)coins;
- (void)storeManagerPurchaseFailed:(NSError *)error;
- (void)storeManagerPurchaseCancelled;
- (void)storeManagerRestoreCompleted:(NSInteger)restoredCount;
- (void)storeManagerRestoreFailed:(NSError *)error;
@end

@interface StoreManager : NSObject

@property (class, nonatomic, readonly) StoreManager *shared;
@property (nonatomic, weak) id<StoreManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<SKProduct *> *products;
@property (nonatomic, assign, readonly) BOOL isLoading;

// Initialize StoreKit
- (void)startStoreKit;

// Load products from App Store
- (void)loadProducts;

// Purchase a product
- (void)purchaseProduct:(SKProduct *)product;

// Restore previous purchases
- (void)restorePurchases;

// Get coins amount for product ID
- (NSInteger)coinsForProductId:(NSString *)productId;

// Get all product IDs
- (NSArray<NSString *> *)allProductIds;

@end

NS_ASSUME_NONNULL_END
