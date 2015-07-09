//
//  PDSharingCenter.h
//  PDUI
//
//  Created by Pavel Diatchenko on 30/04/14.
//  Copyright (c) 2014 Pavel Diatchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h> // Optional

//! Project version number for PDSharingCenter.
FOUNDATION_EXPORT double PDSharingCenterVersionNumber;

//! Project version string for PDSharingCenter.
FOUNDATION_EXPORT const unsigned char PDSharingCenterVersionString[];

typedef void (^PDSharingCenterRequestCompletion)(BOOL commited);

@interface PDSharingCenter : NSObject <UIActivityItemSource, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    UIBarButtonItem *_targetBarButtonItem;
    UIView *_targetView;
    UIViewController *_targetViewController;

    NSString *_companyName;
    NSString *_appName;
    NSString *_appTwitterTag;
    NSString *_supportEmail;
    NSString *_appStoreID;
    NSURL *_appStoreURL;
    NSURL *_appStoreUserReviewsURL;
    NSString *_appStoreURLShortString;

    PDSharingCenterRequestCompletion _feedbackCompletion;
    UIPopoverController *_popoverController;
}

+ (instancetype)shareCenter;

@property (nonatomic, retain) UIBarButtonItem *targetBarButtonItem;
@property (nonatomic, retain) UIView *targetView;
@property (nonatomic, retain) UIViewController *targetViewController;

- (void)shareItems:(NSArray *)objects completion:(void (^)(BOOL commited))completion;

@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appTwitterTag;
@property (nonatomic, copy) NSString *supportEmail;
@property (nonatomic, copy) NSString *appStoreID;
/** If none is set, it is automatically created if either the appStoreID property is set or the companyName and appName properties are set. */
@property (nonatomic, retain) NSURL *appStoreURL;
/** If none is set, it is automatically created by removing the URL schema from appStoreURL. */
@property (nonatomic, retain) NSString *appStoreURLShortString;
/** If none is set, it is automatically created if the appStoreID property is set. */
@property (nonatomic, retain) NSURL *appStoreUserReviewsURL;

- (NSString *)appVersion;
- (NSString *)appVersionShort;

- (void)shareAppWithCompletion:(PDSharingCenterRequestCompletion)completion;
- (void)showAppStoreUserReviews;
- (void)showFeedbackFormWithCompletion:(PDSharingCenterRequestCompletion)completion;
- (void)showFeedbackFormInViewController:(UIViewController *)viewController withCompletion:(PDSharingCenterRequestCompletion)completion;

+ (NSURL *)appStoreURLWithIdentifier:(NSString *)identifier;
+ (NSURL *)appStoreRateURLWithIdentifier:(NSString *)identifier;
+ (NSURL *)appStoreURLWithCompanyName:(NSString *)companyName appName:(NSString *)appName;

- (NSString *)defaultLocalizedShareString;

@end
