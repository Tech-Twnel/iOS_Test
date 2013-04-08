//
//  Chat.m
//  iOS_Test
//
//  Created by Lion User on 08/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//

#import "Chat.h"
#import "XMPP.h"

@interface Chat()
@property (strong, nonatomic) XMPPStream *xmppStream;
@end

@implementation Chat

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
    NSString *jabberId = @"+573105805315@x.twnel.net";
    
    if([self.xmppStream isDisconnected]){
        [self.xmppStream setMyJID:[XMPPJID jidWithString:jabberId]];
    
        NSError *err = nil;
        if(![self.xmppStream connect:&err]){
            NSLog(@"error: %@", err);
            return NO;
        }
    }
    NSLog(@"Connected!");
    return YES;
}

// Disconect from XMPP server.
- (void)disconnect{
    [self goOffline];
    [self.xmppStream disconnect];
}

// Protocol message, connection to the server successful.
- (void) xmppStreamDidConnect: (XMPPStream *)sender{
    NSString *jabberPassword = @"+573105805315";
    NSError *err = nil;
    [self.xmppStream authenticateWithPassword:jabberPassword error:&err];
}

@end
