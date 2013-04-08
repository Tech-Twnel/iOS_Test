//
//  testAppViewController.m
//  iOS_Test
//
//  Created by Lion User on 03/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//

#import "xmppViewController.h"
#import "KeyChaiHandler.h"
#import "Chat.h"

@interface xmppViewController ()
@property (strong, nonatomic) Chat *chat;
@property (weak, nonatomic) IBOutlet UITextView *onlineFriends;
@property (weak, nonatomic) IBOutlet UITextView *messages;
@property (weak, nonatomic) IBOutlet UITextField *toField;
@property (weak, nonatomic) IBOutlet UITextField *messageField;
@end

@implementation xmppViewController

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.chat connect];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Chat *)chat{
    if(!_chat){
        _chat = [[Chat alloc] init];
    }
    
    return _chat;
}

- (IBAction)refreshOnlineFriends{
    NSMutableArray *friends = self.chat.friends;
    NSString *resultString = @"";
    
    for(NSString *friend in friends){
        NSString *tmpString = [NSString stringWithFormat:@"%@\n", friend];
        resultString = [resultString stringByAppendingString: tmpString];
    }
    self.onlineFriends.text = resultString;
    
    NSMutableArray *messages = self.chat.messages;
    resultString = @"";
    for (NSString *message in messages) {
        NSMutableDictionary *msg = (NSMutableDictionary *)message;
        NSString *from = [msg objectForKey:@"sender"];
        NSString *text = [msg objectForKey:@"message"];
        NSString *tmpString = [NSString stringWithFormat:@"%@: %@", from, text];
        resultString = [resultString stringByAppendingString:tmpString];
    }
    self.messages.text = resultString;
    
    [self.view endEditing:YES];
}

- (IBAction)sendMessage {
    NSString *to = self.toField.text;
    to = [to stringByAppendingString:@"@x.twnel.net"];
    NSString *message = self.messageField.text;
    
    if([to length] > 0 && [message length] > 0){
        [self.chat sendMessage:message to:to];
    }
    
    [self.view endEditing:YES];
}

@end
