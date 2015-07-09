//
//  PDSharingCenter.m
//  PDUI
//
//  Created by Pavel Diatchenko on 30/04/14.
//  Copyright (c) 2014 Pavel Diatchenko. All rights reserved.
//

#import "PDSharingCenter.h"

@interface PDSharingCenter ()

@property (nonatomic, strong) UIPopoverController *popoverController;

- (void)mailComposeController:(id)controller didFinishWithResult:(NSInteger)result error:(NSError *)error;

/** Encode the string according to https://developer.apple.com/library/ios/qa/qa1633/_index.htm */
+ (NSString *)stringByEncodingURLFragment:(NSString *)fragment;

@end

@implementation PDSharingCenter

PDSharingCenter *_shareCenter;
+ (instancetype)shareCenter {
    if (!_shareCenter)
        _shareCenter = [[PDSharingCenter alloc] init];
    return _shareCenter;
}

@synthesize targetBarButtonItem = _targetBarButtonItem;
@synthesize targetView = _targetView;
@synthesize targetViewController = _targetViewController;

- (void)setTargetBarButtonItem:(UIBarButtonItem *)targetBarButtonItem {
    _targetBarButtonItem = targetBarButtonItem;
    _targetView = nil;
}

- (void)setTargetView:(UIView *)targetView {
    _targetView = targetView;
    _targetBarButtonItem = nil;
}

@synthesize popoverController = _popoverController;

- (void)shareItems:(NSArray *)objects completion:(void (^)(BOOL commited))completion {
    if (!self.targetViewController) {
        NSLog(@"Need to specify a target view controller.");
        if (completion)
            completion(NO);
        return;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && (!self.targetView && !self.targetBarButtonItem)) {
        NSLog(@"Need to specify a target view or bar button item.");
        if (completion)
            completion(NO);
        return;
    }

    NSLog(@"Sharing %lu items.", (unsigned long)[objects count]);

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:objects applicationActivities:nil];

    NSMutableArray *excludedActivityTypes = [NSMutableArray arrayWithArray:@[UIActivityTypeCopyToPasteboard]];
    activityViewController.excludedActivityTypes = excludedActivityTypes;

    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        self.popoverController = nil;
        if (completion)
            completion(completed);
    };
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        if (self.targetBarButtonItem) {
            [self.popoverController presentPopoverFromBarButtonItem:self.targetBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self.popoverController presentPopoverFromRect:self.targetView.bounds inView:self.targetView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        /*
        if (menuShown)
            menuShown();
         */
    } else {
        //[self.targetViewController presentViewController:activityViewController animated:YES completion:menuShown];
        [self.targetViewController presentViewController:activityViewController animated:YES completion:NULL];
    }
}

@synthesize companyName = _companyName;
@synthesize appName = _appName;
@synthesize appTwitterTag = _appTwitterTag;
@synthesize appStoreID = _appStoreID;
@synthesize appStoreURL = _appStoreURL;
@synthesize appStoreURLShortString = _appStoreURLShortString;
@synthesize appStoreUserReviewsURL = _appStoreUserReviewsURL;

- (NSString *)appName {
    if (!_appName)
        _appName = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey];
    return _appName;
}

- (NSString *)appVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = info[@"CFBundleShortVersionString"];
    appVersion = [appVersion stringByAppendingFormat:@" (%@)", info[(NSString *)kCFBundleVersionKey]];
    return appVersion;
}

- (NSString *)appVersionShort {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = info[@"CFBundleShortVersionString"];
    return appVersion;
}

- (NSString *)appTwitterTag {
    if (!_appTwitterTag) {
        if (!self.appName || self.appName.length == 0)
            return nil;
        NSMutableString *tag = [NSMutableString stringWithString:self.appName];
        NSCharacterSet *characterSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSRange r;
        while ((r = [tag rangeOfCharacterFromSet:characterSet]).location != NSNotFound) {
            [tag replaceCharactersInRange:r withString:@""];
        }
        _appTwitterTag = [NSString stringWithFormat:@"#%@", tag];
    }
    return _appTwitterTag;
}

- (NSURL *)appStoreURL {
    if (!_appStoreURL) {
        if (self.companyName.length != 0 && self.appName.length != 0) {
            _appStoreURL = [PDSharingCenter appStoreURLWithCompanyName:self.companyName appName:self.appName];
        } else if (self.appStoreID.length != 0) {
            _appStoreURL = [PDSharingCenter appStoreURLWithIdentifier:self.appStoreID];
        }
    }
    return _appStoreURL;
}

- (NSString *)appStoreURLShortString {
    if (!_appStoreURLShortString) {
        NSString *urlString = [self.appStoreURL absoluteString];
        if (urlString) {
            // Remove schema
            NSUInteger i = [urlString rangeOfString:@"//"].location;
            if (i != NSNotFound && urlString.length > i + 2) {
                _appStoreURLShortString = [urlString substringFromIndex:i + 2];
            }
        }
    }
    return _appStoreURLShortString;
}

- (NSURL *)appStoreUserReviewsURL {
    if (!_appStoreUserReviewsURL)
        _appStoreUserReviewsURL = [PDSharingCenter appStoreURLWithIdentifier:self.appStoreID];
    return _appStoreUserReviewsURL;
}

/*
- (void)shareAppWithMenuShown:(void (^)())menuShown completion:(void (^)(BOOL commited))completion {
    [self shareItems:@[self] menuShown:menuShown completion:completion];
}
 */
- (void)shareAppWithCompletion:(PDSharingCenterRequestCompletion)completion {
    [self shareItems:@[self] completion:completion];
}

- (void)showAppStoreUserReviews {
    if (!self.appStoreUserReviewsURL || ![[UIApplication sharedApplication] canOpenURL:self.appStoreUserReviewsURL]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil) message:NSLocalizedString(@"Could not rate the app at this time. Please check your internet connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    [[UIApplication sharedApplication] openURL:self.appStoreUserReviewsURL];
}

- (void)showFeedbackFormWithCompletion:(PDSharingCenterRequestCompletion)completion {
    [self showFeedbackFormInViewController:self.targetViewController withCompletion:completion];
}

- (void)showFeedbackFormInViewController:(UIViewController *)viewController withCompletion:(PDSharingCenterRequestCompletion)completion; {
    _feedbackCompletion = completion;

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;

        if (self.appName)
            [controller setSubject:[NSString stringWithFormat:@"%@ v%@", self.appName, self.appVersionShort]];
        if (self.supportEmail)
            [controller setToRecipients:@[self.supportEmail]];

        [viewController presentViewController:controller animated:YES completion:NULL];
    } else {
        NSLog(@"Email is not available.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email Unavailable", @"Email is unavailable.") message:NSLocalizedString(@"Email is not configured. Please check your settings and try again.", @"Email is unavailable.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"To close something.") otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(NSInteger)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    if (_feedbackCompletion)
        _feedbackCompletion(result == MFMailComposeResultSent); // MFMailComposeResultSent
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_feedbackCompletion)
        _feedbackCompletion(NO);
}

+ (NSURL *)appStoreURLWithIdentifier:(NSString *)identifier {
    if (identifier.length == 0)
        return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", identifier]];
}

+ (NSURL *)appStoreRateURLWithIdentifier:(NSString *)identifier {
    if (identifier.length == 0)
        return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=false&type=Purple+Software", identifier]];
}

+ (NSURL *)appStoreURLWithCompanyName:(NSString *)companyName appName:(NSString *)appName {
    if (companyName.length == 0 || appName.length == 0)
        return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.com/apps/%@/%@", [self stringByEncodingURLFragment:companyName], [self stringByEncodingURLFragment:appName]]];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @" ";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    return [self defaultLocalizedShareString];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return (self.appName ? self.appName : @"");
}

+ (NSString *)stringByEncodingURLFragment:(NSString *)fragment {
    if (!fragment || fragment.length == 0)
        return fragment;
    /* Apply the following:
     Remove all whitespace
     Convert all characters to lower-case
     Remove all copyright (©), trademark (™) and registered mark (®) symbols
     Replace ampersands ("&") with "and"
     Remove most punctuation: !¡"#$%'()*+,\-./:;<=>¿?@[\]^_`{|}~
     Replace accented and other "decorated" characters (ü, å, etc.) with their elemental character (u, a, etc.)
     Leave all other characters as-is.
     */

    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];

    NSString *filteredString = [fragment stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    filteredString = [filteredString stringByFoldingWithOptions:(NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch) locale:locale];

    NSMutableString *encodedString = [NSMutableString stringWithString:filteredString];

    NSMutableCharacterSet *removableCharacters = [[NSMutableCharacterSet alloc] init];
    [removableCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [removableCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"©™®"]];
    [removableCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"!¡\"#$%'()*+,\\-./:;<=>¿?@[\\]^_`{|}~"]];

    NSRange removeRange;
    while ((removeRange = [encodedString rangeOfCharacterFromSet:removableCharacters]).location != NSNotFound) {
        [encodedString deleteCharactersInRange:removeRange];
    }

    return [NSString stringWithString:encodedString];
}

- (NSString *)defaultLocalizedShareString {
    NSString *tag = self.appTwitterTag;
    if (!tag)
        tag = self.appName;
    if (!tag)
        return @"";
    NSString *urlString = self.appStoreURLShortString;
    if (!urlString)
        urlString = @"";
    return [NSString stringWithFormat:NSLocalizedString(@"Check out %@. I've been using it on my %@ and I think you will like it too: %@", nil), tag, [[UIDevice currentDevice] model], urlString];
}

@end
