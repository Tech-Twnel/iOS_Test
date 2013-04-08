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
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *messages;
@end

@implementation Chat

// Initialize online friends array.
- (NSMutableArray *)friends{
    if(!_friends){
        _friends = [[NSMutableArray alloc] init];
    }
    return _friends;
}

// Initialize messages array.
- (NSMutableArray *)messages{
    if(!_messages){
        _messages = [[NSMutableArray alloc] init];
    }
    return _messages;
}

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

// Send a message.
- (void)sendMessage:(NSString *)message to:(NSString *)receiver{
    NSXMLElement *xmlBody = [NSXMLElement elementWithName:@"body"];
    [xmlBody setStringValue:message];
    NSXMLElement *xmlMessage = [NSXMLElement elementWithName:@"message"];
    [xmlMessage addAttributeWithName:@"type" stringValue:@"chat"];
    [xmlMessage addAttributeWithName:@"to" stringValue:receiver];
    [xmlMessage addChild:xmlBody];
    [self.xmppStream sendElement:xmlMessage];
    
    NSMutableDictionary *msgAsDictionary = [[NSMutableDictionary alloc] init];
    [msgAsDictionary setObject:message forKey:@"message"];
    [msgAsDictionary setObject:@"you" forKey:@"sender"];
    [self.messages addObject:msgAsDictionary];
    NSLog(@"From: You, Message: %@", message);
    
}

// Protocol message, connection to the server successful.
- (void)xmppStreamDidConnect: (XMPPStream *)sender{
    NSString *jabberPassword = @"+573105805315";
    NSError *err = nil;
    if(![self.xmppStream authenticateWithPassword:jabberPassword error:&err]){
        NSLog(@"error: %@", err);
    } else{
        NSLog(@"Authenticated");
    }
}

// Protocol message, authentication sucessfull.
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [self goOnline];
    NSLog(@"Status online");
}

// Protocol message, a friend went offline/online.
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceType = [presence type]; // Online/Offline
    NSString *myJID = [[sender myJID] user];
    NSString *fromJID = [[presence from] user];
    
    if(![fromJID isEqualToString:myJID]){
        if([presenceType isEqualToString:@"available"]){
            [self.friends addObject:fromJID];
            NSLog(@"(online) %@", fromJID);
        } else if([presenceType isEqualToString:@"unavailable"]){
            [self.friends removeObject:fromJID];
            NSLog(@"(offline) %@", fromJID);
        }
    }
}

// Protocol message, message received.
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSMutableDictionary *msgAsDictionary = [[NSMutableDictionary alloc] init];
    [msgAsDictionary setObject:msg forKey:@"message"];
    [msgAsDictionary setObject:from forKey:@"sender"];
    [self.messages addObject:msgAsDictionary];
    NSLog(@"From: %@, Message: %@", from, msg);
}

@end
