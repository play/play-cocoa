//
//  PLPlayClient.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAPlayClient.h"
#import "AFJSONRequestOperation.h"

NSString * const kPLBaseURLString = @"https://play.githubapp.com";

@implementation PLAPlayClient

+ (PLAPlayClient *)sharedClient {
  static PLAPlayClient *_sharedClient = nil;
  static dispatch_once_t oncePredicate;
  
  dispatch_once(&oncePredicate, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kPLBaseURLString]];
  });
  
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
	[self setDefaultHeader:@"Accept-Encoding" value:@"gzip,deflate"];
  
  return self;
}









@end
