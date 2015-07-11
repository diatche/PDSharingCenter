# PDSharingCenter
Easily implement native sharing for social networks, email and SMS.

## Setup
```objc
PDSharingCenter *center = [PDSharingCenter defaultCenter];

// Set at least the app name and company name
center.companyName = @"companyName";
center.appName = @"appName";
center.appTwitterTag = @"appTwitterTag";
center.supportEmail = @"supportEmail";
center.appStoreID = @"appStoreID";
```

## Usage
```objc
[center shareItems:@[@"Some text", [UIImage imageNamed:@"someImage"]] completion:NULL];
```
