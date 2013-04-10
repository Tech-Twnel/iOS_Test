//  Twnel Apps
//  Santiago Castillo <santiago@twnel.com>
//
//  Created on 05/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//
//  This class manages HTTP connections used to access web services.
//  Data is sent and expected to be received in JSON format.

#import <Foundation/Foundation.h>

@protocol HTTPHandlerDelegate;

@interface HTTPHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
// Designated initializer.
- (HTTPHandler *)initWithURL:(NSURL *)url delegate:(id <HTTPHandlerDelegate>)delegate;
// Initiates HTTP connection, request body is sent in JSON format.
// Response is expected to be in JSON aswell.
- (void)sendRequestWithData:(NSDictionary *)data;
// Retreives the JSON response loaded from the server.
// Returns a dictionary representing the JSON
- (id)getResponse:(NSError **)error;
@end

// Delegate gets notified when an error occurs or when the response is done loading.
@protocol HTTPHandlerDelegate
@required
// Request finished loading, it is now possible to retreive the response.
- (void)didFinishHTTPRequest:(HTTPHandler *)handler;
// En error occurred while requesting the server for a response.
- (void)errorReceived:(NSError *)error fromHTTPHandler:(HTTPHandler *)handler;
@end
