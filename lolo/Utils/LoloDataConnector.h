//
//  LoloDataConnector.h
//  lolo
//
//  Created on 2026/2/11.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoloDataConnectorDelegate <NSObject>
@optional
- (void)connectorDidLoadProducts:(NSArray<SKProduct *> *)products;
- (void)connectorProductsLoadFailed:(NSError *)error;
- (void)connectorPurchaseSucceeded:(SKProduct *)product coins:(NSInteger)coins;
- (void)connectorPurchaseFailed:(NSError *)error;
- (void)connectorPurchaseCancelled;
- (void)connectorRestoreCompleted:(NSInteger)count;
- (void)connectorRestoreFailed:(NSError *)error;
@end

@interface LoloDataConnector : NSObject

@property (nonatomic, weak) id<LoloDataConnectorDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<SKProduct *> *products;
@property (nonatomic, assign, readonly) BOOL isLoading;

+ (LoloDataConnector *)defaultConnector;

/// Register as payment transaction observer
- (void)startObserving;

/// Request product information from App Store
- (void)loadProducts;

/// Initiate a purchase for a product
- (void)purchaseProduct:(SKProduct *)product;

/// Restore previous purchases
- (void)restorePurchases;

/// Get coin value for a product identifier
- (NSInteger)coinsForProductIdentifier:(NSString *)productIdentifier;

/// Get all registered product identifiers
- (NSArray<NSString *> *)allProductIdentifiers;

@end

NS_ASSUME_NONNULL_END
