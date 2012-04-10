//
//  PLPlayClient.h
//  Play
//
//  Created by Jon Maddox on 2/9/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "AFHTTPClient.h"

@interface PLAPlayClient : AFHTTPClient

+ (id)sharedClient;

@end
