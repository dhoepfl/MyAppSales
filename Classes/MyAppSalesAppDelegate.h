//
//  ASiSTAppDelegate.h
//  ASiST
//
//  Created by Oliver Drobnik on 18.12.08.
//  Copyright drobnik.com 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PinLockController.h"



@class   HTTPServer, YahooFinance;

@class iTunesConnect, AppViewController, SettingsViewController, Report_v1, KeychainWrapper, App, StatusInfoController, Account;
@class ReportsGroupsAndTypeSelectionViewController;

@interface MyAppSalesAppDelegate : NSObject <UIApplicationDelegate, PinLockDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	UITabBarController *tabBarController;
	
	AppViewController *appViewController;
	ReportsGroupsAndTypeSelectionViewController *reportRootController;
	SettingsViewController *settingsViewController;
	IBOutlet StatusInfoController *statusViewController;
	
	// HTTP server
	HTTPServer *httpServer;
	NSDictionary *addresses;
	BOOL serverIsRunning;
	
	
	IBOutlet UITabBarItem* appBadgeItem;
	IBOutlet UITabBarItem* reportBadgeItem;
	IBOutlet UIBarButtonItem* refreshButton;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UITabBarItem* appBadgeItem;
@property (nonatomic, retain) IBOutlet UITabBarItem* reportBadgeItem;
//@property (nonatomic, retain) iTunesConnect *itts;

@property (nonatomic, readonly, assign) BOOL serverIsRunning;

@property (nonatomic, retain) HTTPServer *httpServer;
@property (nonatomic, retain) NSDictionary *addresses;



@property (nonatomic, retain) IBOutlet ReportsGroupsAndTypeSelectionViewController *reportRootController;
@property (nonatomic, retain) IBOutlet AppViewController *appViewController;

@property (nonatomic, retain) IBOutlet SettingsViewController *settingsViewController;
@property (nonatomic, retain) IBOutlet StatusInfoController *statusViewController;


//@property (nonatomic, retain) KeychainWrapper *keychainWrapper;


- (void) toggleNetworkIndicator:(BOOL)isON;


// Notification handlers
- (void)newFileInDocuments:(NSNotification *) notification;

- (void) startSync;
- (void) emptyCache;


@end

