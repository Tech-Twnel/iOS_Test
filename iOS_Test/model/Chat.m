//
//  connection.m
//  iOS_Test
//
//  Created by Lion User on 05/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//

#import "Chat.h"
#import "XMPP.h"

// Constants referring to key values on UserDefaults. 
NSString * const USER_ID = @"userId";

@interface connection()
@property (strong, nonatomic) XMPPStream *xmppStream;
@end

@implementation connection

// Initialize the stream.
- (XMPPStream *)xmppStream{
    if(!_xmppStream){
        _xmppStream = [[XMPPStream alloc] init];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return _xmppStream;
}

// Notify online presence.
- (void)goOnline{
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
}

// Notify offline status.
- (void)goOffline{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

// Connect and authenticate with the XMPP server.
- (BOOL)connect{
    NSString *jabberId = [[NSUserDefaults standardUserDefaults] stringForKey:USER_ID];
    NSString *password = []
}


@end