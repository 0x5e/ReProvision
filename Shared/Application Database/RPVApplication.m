//
//  RPVApplication.m
//  iOS
//
//  Created by Matt Clarke on 09/01/2018.
//  Copyright © 2018 Matt Clarke. All rights reserved.
//

#import "RPVApplication.h"

@interface LSApplicationProxy : NSObject

@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSURL *bundleURL;

+ (instancetype)applicationProxyForIdentifier:(NSString*)arg1;

- (id)localizedName;
- (id)primaryIconDataForVariant:(int)arg1;
@end

@interface UIImage (Private)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface RPVApplication ()
@property (nonatomic, strong) LSApplicationProxy *proxy;
@end

@implementation RPVApplication

- (instancetype)initWithApplicationProxy:(LSApplicationProxy*)proxy {
    self = [super init];
    
    if (self) {
        self.proxy = proxy;
    }
    
    return self;
}

- (NSString*)bundleIdentifier {
    return self.proxy != nil ? self.proxy.applicationIdentifier : @"com.mycompany.example";
}

- (NSString*)applicationName {
    return self.proxy != nil ? [self.proxy localizedName] : @"Example";
}

- (UIImage*)applicationIcon {
    UIImage *icon;
    
    if (self.proxy != nil) {
        icon = [UIImage _applicationIconImageForBundleIdentifier:[self bundleIdentifier] format:0 scale:[UIScreen mainScreen].scale];
    } else {
        icon = [UIImage imageNamed:@"AppIcon40x40"];
    }
    
    return icon;
}

- (NSDate*)applicationExpiryDate {
    if (!self.proxy) {
        // Date that is 2 days away.
        return [NSDate dateWithTimeIntervalSinceNow:172800];
    }
    
    //LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:[self bundleIdentifier]];
    NSString *provisionPath = [[self.proxy.bundleURL path] stringByAppendingString:@"/embedded.mobileprovision"];
    
    NSDictionary *provision = [self _provisioningProfileAtPath:provisionPath];
    
    return [provision objectForKey:@"ExpirationDate"];
}

- (NSURL*)locationOfApplicationOnFilesystem {
    return self.proxy.bundleURL;
}

- (NSDictionary *)_provisioningProfileAtPath:(NSString *)path {
    NSError *err;
    NSString *stringContent = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&err];
    stringContent = [stringContent componentsSeparatedByString:@"<plist version=\"1.0\">"][1];
    stringContent = [NSString stringWithFormat:@"%@%@", @"<plist version=\"1.0\">", stringContent];
    stringContent = [stringContent componentsSeparatedByString:@"</plist>"][0];
    stringContent = [NSString stringWithFormat:@"%@%@", stringContent, @"</plist>"];
    
    NSData *stringData = [stringContent dataUsingEncoding:NSASCIIStringEncoding];
    
    NSError *error;
    NSPropertyListFormat format;
    
    id plist = [NSPropertyListSerialization propertyListWithData:stringData options:NSPropertyListImmutable format:&format error:&error];
    
    return plist;
}

@end
