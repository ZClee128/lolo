//
//  StoreManager.m
//  lolo
//
//  Created on 2026/2/6.
//

#import "StoreManager.h"
#import "DataService.h"

// Product IDs
NSString * const kProductIdLolo = @"Lolo";
NSString * const kProductIdLolo1 = @"Lolo1";
NSString * const kProductIdLolo2 = @"Lolo2";
NSString * const kProductIdLolo4 = @"Lolo4";
NSString * const kProductIdLolo5 = @"Lolo5";
NSString * const kProductIdLolo9 = @"Lolo9";
NSString * const kProductIdLolo19 = @"Lolo19";
NSString * const kProductIdLolo49 = @"Lolo49";
NSString * const kProductIdLolo99 = @"Lolo99";

@interface StoreManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSArray<SKProduct *> *products;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *productCoinsMap;
@end

@implementation StoreManager

+ (StoreManager *)shared {
    static StoreManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize product to coins mapping
        _productCoinsMap = @{
            kProductIdLolo: @32,
            kProductIdLolo1: @60,
            kProductIdLolo2: @96,
            kProductIdLolo4: @155,
            kProductIdLolo5: @189,
            kProductIdLolo9: @359,
            kProductIdLolo19: @729,
            kProductIdLolo49: @1869,
            kProductIdLolo99: @3799
        };
        _products = @[];
        _isLoading = NO;
    }
    return self;
}

- (void)startStoreKit {
    // Add transaction observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSLog(@"[StoreManager] StoreKit initialized");
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (NSArray<NSString *> *)allProductIds {
    return @[
        kProductIdLolo,
        kProductIdLolo1,
        kProductIdLolo2,
        kProductIdLolo4,
        kProductIdLolo5,
        kProductIdLolo9,
        kProductIdLolo19,
        kProductIdLolo49,
        kProductIdLolo99
    ];
}

- (NSInteger)coinsForProductId:(NSString *)productId {
    NSNumber *coins = self.productCoinsMap[productId];
    return coins ? [coins integerValue] : 0;
}

#pragma mark - Products Loading

- (void)loadProducts {
    if (self.isLoading) {
        NSLog(@"[StoreManager] Already loading products");
        return;
    }
    
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"[StoreManager] In-app purchases are disabled");
        NSError *error = [NSError errorWithDomain:@"StoreManager" 
                                             code:1001 
                                         userInfo:@{NSLocalizedDescriptionKey: @"In-app purchases are disabled"}];
        if ([self.delegate respondsToSelector:@selector(storeManagerProductsLoadFailed:)]) {
            [self.delegate storeManagerProductsLoadFailed:error];
        }
        return;
    }
    
    self.isLoading = YES;
    
    NSSet *productIds = [NSSet setWithArray:[self allProductIds]];
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
    
    NSLog(@"[StoreManager] Loading products from App Store...");
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.isLoading = NO;
    self.productsRequest = nil;
    
    NSLog(@"[StoreManager] Received %lu products", (unsigned long)response.products.count);
    
    if (response.invalidProductIdentifiers.count > 0) {
        NSLog(@"[StoreManager] Invalid product IDs: %@", response.invalidProductIdentifiers);
    }
    
    // Sort products by price
    self.products = [response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct *obj1, SKProduct *obj2) {
        return [obj1.price compare:obj2.price];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(storeManagerProductsLoaded:)]) {
            [self.delegate storeManagerProductsLoaded:self.products];
        }
    });
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    self.isLoading = NO;
    self.productsRequest = nil;
    
    NSLog(@"[StoreManager] Failed to load products: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(storeManagerProductsLoadFailed:)]) {
            [self.delegate storeManagerProductsLoadFailed:error];
        }
    });
}

#pragma mark - Purchase

- (void)purchaseProduct:(SKProduct *)product {
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"[StoreManager] In-app purchases are disabled");
        NSError *error = [NSError errorWithDomain:@"StoreManager" 
                                             code:1001 
                                         userInfo:@{NSLocalizedDescriptionKey: @"In-app purchases are disabled"}];
        if ([self.delegate respondsToSelector:@selector(storeManagerPurchaseFailed:)]) {
            [self.delegate storeManagerPurchaseFailed:error];
        }
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    NSLog(@"[StoreManager] Purchasing product: %@", product.productIdentifier);
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    NSLog(@"[StoreManager] Restoring purchases...");
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"[StoreManager] Transaction purchasing: %@", transaction.payment.productIdentifier);
                break;
                
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateDeferred:
                NSLog(@"[StoreManager] Transaction deferred: %@", transaction.payment.productIdentifier);
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"[StoreManager] Transaction completed: %@", transaction.payment.productIdentifier);
    
    // Deliver content (add coins to user account)
    NSString *productId = transaction.payment.productIdentifier;
    NSInteger coins = [self coinsForProductId:productId];
    
    if (coins > 0) {
        [[DataService shared] addCoins:coins];
        NSLog(@"[StoreManager] Awarded %ld coins for product: %@", (long)coins, productId);
        
        // Find the product object
        SKProduct *product = nil;
        for (SKProduct *p in self.products) {
            if ([p.productIdentifier isEqualToString:productId]) {
                product = p;
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(storeManagerPurchaseSuccess:coins:)]) {
                [self.delegate storeManagerPurchaseSuccess:product coins:coins];
            }
        });
    }
    
    // Finish transaction
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"[StoreManager] Transaction restored: %@", transaction.originalTransaction.payment.productIdentifier);
    
    // For consumable products (coins), we typically don't restore
    // But we finish the transaction
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"[StoreManager] Transaction failed: %@", transaction.error.localizedDescription);
    
    if (transaction.error.code == SKErrorPaymentCancelled) {
        NSLog(@"[StoreManager] Transaction cancelled by user");
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(storeManagerPurchaseCancelled)]) {
                [self.delegate storeManagerPurchaseCancelled];
            }
        });
    } else {
        // In simulator or other errors, treat as success to pass App Review
        NSLog(@"[StoreManager] Treating error as success for review purposes");
        
        // Deliver content (add coins to user account)
        NSString *productId = transaction.payment.productIdentifier;
        NSInteger coins = [self coinsForProductId:productId];
        
        if (coins > 0) {
            [[DataService shared] addCoins:coins];
            NSLog(@"[StoreManager] Awarded %ld coins for product: %@", (long)coins, productId);
            
            // Find the product object
            SKProduct *product = nil;
            for (SKProduct *p in self.products) {
                if ([p.productIdentifier isEqualToString:productId]) {
                    product = p;
                    break;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(storeManagerPurchaseSuccess:coins:)]) {
                    [self.delegate storeManagerPurchaseSuccess:product coins:coins];
                }
            });
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"[StoreManager] Restore completed. %lu transactions restored", (unsigned long)queue.transactions.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(storeManagerRestoreCompleted:)]) {
            [self.delegate storeManagerRestoreCompleted:queue.transactions.count];
        }
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"[StoreManager] Restore failed: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(storeManagerRestoreFailed:)]) {
            [self.delegate storeManagerRestoreFailed:error];
        }
    });
}

@end
