//  Twnel Apps
//  Santiago Castillo <santiago@twnel.com>
//
//  Created on 05/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//
//  This class manages HTTP connections used to access web services.
//  Data is sent and expected to be received in JSON format.

#import "HTTPHandler.h"

#pragma mark Handle HTTP POST requests.
#pragma mark-

@interface HTTPHandler()
// Delegate gets notified when an error occurs or when the response is done loading.
@property (assign, nonatomic) id <HTTPHandlerDelegate> delegate;
// Server's URL
@property (strong, nonatomic) NSURL *url;
// This property is only usable after self.loaded has been set to YES.
@property (strong, nonatomic) NSMutableData *responseData;
// Indicates whether the response finished loading or not.
@property (nonatomic) BOOL loaded;
@end

// Use designated initializer instead.
@implementation HTTPHandler

- (HTTPHandler *)init{
    return nil;
}

#pragma mark-
#pragma mark Designated Initializer
#pragma mark-
// Designated initializer.
- (HTTPHandler *)initWithURL:(NSURL *)url delegate:(id <HTTPHandlerDelegate>)delegate{
    self = [super init];
    if(self){
        self.delegate = delegate;
        self.url = url;
    }
    return self;
}

#pragma mark-
#pragma mark Public Methods
#pragma mark-
// Initiates HTTP connection, request body is sent in JSON format.
// Response is expected to be in JSON aswell.
- (void)sendRequestWithData:(NSDictionary *)data{
    NSError *error = nil;
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error];
    
    if(jsonData){
        // JSON data was created.
        // Create HTTP POST request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        
        // Send a connection with the POST request.
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if(connection){
            // Connection sent without errors, initalize data holder.
            self.loaded = NO;
            self.responseData = [NSMutableData data];
        } else{
            // Error while attempting connection.
            NSDictionary *details = @{NSLocalizedDescriptionKey: @"Connection couldn't be initialized."};
            NSError *customError = [NSError errorWithDomain:@"Connection error." code:0 userInfo:details];
            [self.delegate errorReceived:customError fromHTTPHandler:self];
        }
    } else{
        // Error occurred while parsing the dictionary parameter into JSON data.
        NSDictionary *details = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dictionary may not be a property list, JSON parse error <%@>", [error.userInfo objectForKey:NSLocalizedDescriptionKey]? error.userInfo[NSLocalizedDescriptionKey]: @"No description available."]};
        NSError *customError = [NSError errorWithDomain:@"JSON parser error." code:error.code userInfo:details];
        [self.delegate errorReceived:customError fromHTTPHandler:self];
    }
}

// Retreives the JSON response loaded from the server.
// Returns a dictionary representing the JSON
- (id)getResponse:(NSError **)error{
    id response = nil;
    
    if (self.loaded) {
        // The response finished loaded.
        NSError *error = nil;
        response = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if(!response){
            // Error occurred while parsing the JSON data into an object.
            NSDictionary *details = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't parse JSON data <%@>. Error received: <%@>", self.responseData, [error.userInfo objectForKey:NSLocalizedDescriptionKey]? error.userInfo[NSLocalizedDescriptionKey]: @"No description available."]};
            NSError *customError = [NSError errorWithDomain:@"JSON parser error." code:error.code userInfo:details];
            [self.delegate errorReceived:customError fromHTTPHandler:self];
        }
    } else{
        // The response hasn't loaded yet.
        NSDictionary *details = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No response received from URL <%@> yet.", self.url]};
        *error = [NSError errorWithDomain:@"Response hasn't loaded yet." code:0 userInfo:details];
    }
    
    return response;
}

#pragma mark-
#pragma mark Protocol Methods
#pragma mark-
// Protocol method, connection was successfull.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    // Data stream will be initiated.
    [self.responseData setLength:0];
}

// Protocol method, chunk of data received.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    // Append newly arrived chunk of data.
    [self.responseData appendData:data];
}

// Protocol method, an error occurred while rloading the response.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.responseData setLength:0];
    [self.delegate errorReceived:error fromHTTPHandler:self];
}

// Protocol method, response loaded.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    // Response fully loaded, notify delegate.
    self.loaded = YES;
    [self.delegate didFinishHTTPRequest:self];
}

@end