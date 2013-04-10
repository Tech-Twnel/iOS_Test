//
//  Chat.h
//  iOS_Test
//
//  Created by Lion User on 08/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@interface Chat : NSObject <XMPPStreamDelegate>
@property (readonly, strong, nonatomic)NSMutableArray *friends;
@property (readonly, strong, nonatomic)NSMutableArray *messages;
- (BOOL)connect;
- (void)sendMessage:(NSString *)message to:(NSString *)receiver;
@end
