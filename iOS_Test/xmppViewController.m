//
//  testAppViewController.m
//  iOS_Test
//
//  Created by Lion User on 03/04/2013.
//  Copyright (c) 2013 Twnel. All rights reserved.
//

#import "xmppViewController.h"
#import "KeyChaiHandler.h"

@interface xmppViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@end

@implementation xmppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePassword {
    NSString *password = self.passwordField.text;
    BOOL comp = [KeyChaiHandler isEqualToStoredPassword:password];
    BOOL err = [KeyChaiHandler storePassword:password];
    
    self.passwordLabel.text = [NSString stringWithFormat:@"Compare: %u, Store: %u", comp, err];
    
}

@end
