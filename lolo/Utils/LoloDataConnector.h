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
- (void)connectorDidSyncConfigs:(NSArray<SKProduct *> *)configs;
- (void)connectorSyncFailed:(NSError *)error;
- (void)connectorSessionUpdated:(SKProduct *)config value:(NSInteger)value;
- (void)connectorSessionUpdateFailed:(NSError *)error;
- (void)connectorSessionCancelled;
- (void)connectorDataRestored:(NSInteger)count;
- (void)connectorRestoreFailed:(NSError *)error;
@end

@interface LoloDataConnector : NSObject

@property (class, nonatomic, readonly) LoloDataConnector *defaultConnector;
@property (nonatomic, weak) id<LoloDataConnectorDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray<SKProduct *> *remoteConfigs;
@property (nonatomic, assign, readonly) BOOL isSyncing;

// Initialize Connection
- (void)establishConnection;

// Sync remote config
- (void)syncRemoteConfig;

// Update session with config
- (void)updateSession:(SKProduct *)config;

// Refresh session data
- (void)refreshSessionData;

// Get value for config key
- (NSInteger)valueForConfigKey:(NSString *)key;

// Get all config keys
- (NSArray<NSString *> *)allConfigKeys;

@end

NS_ASSUME_NONNULL_END
