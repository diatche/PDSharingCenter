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

+ (nonnull instancetype)defaultCenter;

@property (nonatomic, retain, nullable) UIBarButtonItem *targetBarButtonItem;
@property (nonatomic, retain, nullable) UIView *targetView;
@property (nonatomic, retain, nullable) UIViewController *targetViewController;

- (void)shareItems:(nonnull NSArray *)objects completion:(nullable void (^)(BOOL commited))completion;

@property (nonatomic, copy, nullable) NSString *companyName;
@property (nonatomic, copy, nullable) NSString *appName;
@property (nonatomic, copy, nullable) NSString *appTwitterTag;
@property (nonatomic, copy, nullable) NSString *supportEmail;
@property (nonatomic, copy, nullable) NSString *appStoreID;
/** If none is set, it is automatically created if either the appStoreID property is set or the companyName and appName properties are set. */
@property (nonatomic, copy, nullable) NSURL *appStoreURL;
/** If none is set, it is automatically created by removing the URL schema from appStoreURL. */
@property (nonatomic, copy, nullable) NSString *appStoreURLShortString;
/** If none is set, it is automatically created if the appStoreID property is set. */
@property (nonatomic, copy, nullable) NSURL *appStoreUserReviewsURL;

- (nullable NSString *)appVersion;
- (nullable NSString *)appVersionShort;

- (void)shareAppWithCompletion:(nullable PDSharingCenterRequestCompletion)completion;
- (void)showAppStoreUserReviews;
- (void)showFeedbackFormWithCompletion:(nullable PDSharingCenterRequestCompletion)completion;
- (void)showFeedbackFormInViewController:(nonnull UIViewController *)viewController withCompletion:(nullable PDSharingCenterRequestCompletion)completion;

+ (nonnull NSURL *)appStoreURLWithIdentifier:(nonnull NSString *)identifier;
+ (nonnull NSURL *)appStoreRateURLWithIdentifier:(nonnull NSString *)identifier;
+ (nonnull NSURL *)appStoreURLWithCompanyName:(nonnull NSString *)companyName appName:(nonnull NSString *)appName;

- (nonnull NSString *)defaultLocalizedShareString;

@end
