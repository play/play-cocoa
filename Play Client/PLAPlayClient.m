//
//  PLPlayClient.m
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "PLAPlayClient.h"
#import "AFJSONRequestOperation.h"
#import "PLAController.h"

@implementation PLAPlayClient

+ (PLAPlayClient *)sharedClient {
  static PLAPlayClient *_sharedClient = nil;
  static dispatch_once_t oncePredicate;
  
  dispatch_once(&oncePredicate, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[[PLAController sharedController] playUrl]]];
  });
  
  // This isn't pretty, but baseURL is readonly. So we can't actually 
  // keep it a singleton and adjust the url based on user input at runtime.
  if (![[[_sharedClient baseURL] absoluteString] isEqualToString:[[PLAController sharedController] playUrl]]) {
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:[[PLAController sharedController] playUrl]]];
  }
  
  [_sharedClient setDefaultHeader:@"Authorization" value:[[PLAController sharedController] authToken]];

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
	[self setDefaultHeader:@"Authorization" value:[[PLAController sharedController] authToken]];
  
  return self;
}

@end
