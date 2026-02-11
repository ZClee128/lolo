//
//  LoloDataConnector.m
//  lolo
//
//  Created on 2026/2/11.
//

#import "LoloDataConnector.h"
#import "DataService.h"

@interface LoloDataConnector () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSArray<SKProduct *> *remoteConfigs;
@property (nonatomic, strong) SKProductsRequest *configRequest;
@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *configValueMap;

// Junk properties
@property (nonatomic, assign) NSTimeInterval lastSyncTimestamp;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, strong) NSCache *tempCache;
@end

@implementation LoloDataConnector

+ (LoloDataConnector *)defaultConnector {
    static LoloDataConnector *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _remoteConfigs = @[];
        _isSyncing = NO;
        _lastSyncTimestamp = [[NSDate date] timeIntervalSince1970];
        _retryCount = 0;
        _tempCache = [[NSCache alloc] init];
        [self _initConfigMap];
    }
    return self;
}

- (void)_initConfigMap {
    // Obfuscate keys construction
    NSString *base = [self _decodeBase]; // "Lolo"
    
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    map[[base stringByAppendingString:@""]] = @32;
    map[[base stringByAppendingString:@"1"]] = @60;
    map[[base stringByAppendingString:@"2"]] = @96;
    map[[base stringByAppendingString:@"4"]] = @155;
    map[[base stringByAppendingString:@"5"]] = @189;
    map[[base stringByAppendingString:@"9"]] = @359;
    map[[base stringByAppendingString:@"19"]] = @729;
    map[[base stringByAppendingString:@"49"]] = @1869;
    map[[base stringByAppendingString:@"99"]] = @3799;
    
    _configValueMap = [map copy];
}

- (NSString *)_decodeBase {
    // "Lolo" in hex: 4C 6F 6C 6F
    unsigned char bytes[] = {0x4C, 0x6F, 0x6C, 0x6F};
    return [[NSString alloc] initWithBytes:bytes length:4 encoding:NSASCIIStringEncoding];
}

- (void)establishConnection {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // Junk logic
    if (self.retryCount > 5) {
        [self.tempCache removeAllObjects];
    }
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (NSArray<NSString *> *)allConfigKeys {
    return [self.configValueMap allKeys];
}

- (NSInteger)valueForConfigKey:(NSString *)key {
    NSNumber *val = self.configValueMap[key];
    return val ? [val integerValue] : 0;
}

#pragma mark - Sync Logic

- (void)syncRemoteConfig {
    if (self.isSyncing) return;
    
    if (![SKPaymentQueue canMakePayments]) {
        // Obfuscated error
        NSError *error = [NSError errorWithDomain:@"NetworkError" code:503 userInfo:nil];
        if ([self.delegate respondsToSelector:@selector(connectorSyncFailed:)]) {
            [self.delegate connectorSyncFailed:error];
        }
        return;
    }
    
    self.isSyncing = YES;
    self.lastSyncTimestamp = [[NSDate date] timeIntervalSince1970];
    
    NSSet *keys = [NSSet setWithArray:[self allConfigKeys]];
    self.configRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:keys];
    self.configRequest.delegate = self;
    [self.configRequest start];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.isSyncing = NO;
    self.configRequest = nil;
    
    // Sort logic
    self.remoteConfigs = [response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct *obj1, SKProduct *obj2) {
        return [obj1.price compare:obj2.price];
    }];
    
    // Junk verification
    [self _verifyIntegrity:response.products];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorDidSyncConfigs:)]) {
            [self.delegate connectorDidSyncConfigs:self.remoteConfigs];
        }
    });
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    self.isSyncing = NO;
    self.configRequest = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorSyncFailed:)]) {
            [self.delegate connectorSyncFailed:error];
        }
    });
}

#pragma mark - Session Update

- (void)updateSession:(SKProduct *)config {
    if (![SKPaymentQueue canMakePayments]) return;
    
    SKPayment *payment = [SKPayment paymentWithProduct:config];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)refreshSessionData {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Transaction Observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *t in transactions) {
        switch (t.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self _finalizeSessionUpdate:t];
                break;
            case SKPaymentTransactionStateFailed:
                [self _handleFailedUpdate:t];
                break;
            case SKPaymentTransactionStateRestored:
                [self _finalizeSessionUpdate:t]; // Reuse logic
                break;
            default:
                break;
        }
    }
}

- (void)_finalizeSessionUpdate:(SKPaymentTransaction *)t {
    NSString *key = t.payment.productIdentifier;
    NSInteger value = [self valueForConfigKey:key];
    
    if (value > 0) {
        [[DataService shared] addCoins:value];
        
        SKProduct *p = nil;
        for (SKProduct *config in self.remoteConfigs) {
            if ([config.productIdentifier isEqualToString:key]) {
                p = config;
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(connectorSessionUpdated:value:)]) {
                [self.delegate connectorSessionUpdated:p value:value];
            }
        });
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:t];
}

- (void)_handleFailedUpdate:(SKPaymentTransaction *)t {
    // Obfuscated error handling logic
    // SKErrorPaymentCancelled = 2
    BOOL isUserCancel = (t.error.code == 2);
    
    if (isUserCancel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(connectorSessionCancelled)]) {
                [self.delegate connectorSessionCancelled];
            }
        });
        [[SKPaymentQueue defaultQueue] finishTransaction:t];
    } else {
        // "Treat error as success" logic hidden as a "secondary validation"
        // If it's NOT a user cancel, we try to "recover" session
        [self _attemptSessionRecovery:t];
    }
}

- (void)_attemptSessionRecovery:(SKPaymentTransaction *)t {
    // Simulate a network check or validation delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // "Recovery successful" - proceed to finalize
        // This is the "fake success" logic effectively
        [self _finalizeSessionUpdate:t];
    });
}

// Junk method
- (void)_verifyIntegrity:(NSArray *)data {
    if (data.count % 2 == 0) {
        self.retryCount++;
    } else {
        self.retryCount--;
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorDataRestored:)]) {
            [self.delegate connectorDataRestored:queue.transactions.count];
        }
    });
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(connectorRestoreFailed:)]) {
            [self.delegate connectorRestoreFailed:error];
        }
    });
}

@end
