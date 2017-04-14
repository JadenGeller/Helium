//
//  WKWebViewPrivate.h
//  Helium
//
//  Created by Jaden Geller on 4/13/15.
//  Copyright (c) 2015 Jaden Geller. All rights reserved.
//

@import WebKit;

@interface WKWebView (Privates)

@property (copy, setter=_setCustomUserAgent:) NSString *_customUserAgent;

@property (nonatomic, readonly) NSString *_userAgent;

@end