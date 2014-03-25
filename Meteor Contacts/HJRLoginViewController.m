//
//  HJRLoginViewController.m
//  Meteor Contacts
//
//  Created by Hamish Rickerby on 25/03/2014.
//  Copyright (c) 2014 happtic consulting. All rights reserved.
//

#import "HJRLoginViewController.h"
#import "HJRContactListTableViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <ObjectiveDDP/MeteorClient.h>

@interface HJRLoginViewController ()
@property (nonatomic, weak) IBOutlet UITextField *serverAddress;
@property (nonatomic, weak) IBOutlet UITextField *email;
@property (nonatomic, weak) IBOutlet UITextField *password;
@property (nonatomic, assign) BOOL attemptToLogin;
@property (nonatomic, strong) MeteorClient *meteorClient;
- (IBAction)loginTapped:(id)sender;
@end

@implementation HJRLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.meteorClient = [[MeteorClient alloc] init];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportConnection) name:MeteorClientDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportDisconnection) name:MeteorClientDidDisconnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(meteorConnected) name:@"connected" object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ContactsListSegue"]) {
    HJRContactListTableViewController *destination = segue.destinationViewController;
    [destination setMeteorClient:self.meteorClient];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.meteorClient disconnect];
  [self.meteorClient.ddp setDelegate:nil];
  self.meteorClient.ddp = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)loginTapped:(id)sender {
  // Need to do this because we have to establish the websocket connection, and then login can work.
  self.attemptToLogin = YES;
  [self.serverAddress resignFirstResponder];
  [self.email resignFirstResponder];
  [self.password resignFirstResponder];
  
  NSString *serverAddress = [NSString stringWithFormat:@"wss://%@/websocket", self.serverAddress.text];

  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  [hud setLabelText:@"Connecting"];
  [hud setDetailsLabelText:serverAddress];

  ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:serverAddress delegate:self.meteorClient];
  self.meteorClient.ddp = ddp;
  [self.meteorClient.ddp connectWebSocket];
  }

- (void)reportConnection {
  NSLog(@"Connected to websocketserver at %@", self.meteorClient.ddp.urlString);
  if (self.meteorClient.websocketReady && self.meteorClient.connected) {
    [self executeLogin];
  }
}

- (void)reportDisconnection {
  NSLog(@"Lost connection to server at %@", self.meteorClient.ddp.urlString);
  [self.meteorClient disconnect];
  MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
  [hud setLabelText:@"Login failed"];
  [hud setDetailsLabelText:@"Check details and try again"];
  [hud hide:YES afterDelay:3.0];
}

- (void)meteorConnected {
  NSLog(@"Meteor Connected");
  if (self.meteorClient.websocketReady && self.meteorClient.connected) {
    [self executeLogin];
  }
}

- (void)executeLogin {
  MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
  [hud setLabelText:@"Connected"];
  [hud setDetailsLabelText:@"Logging In"];
  if (self.attemptToLogin) {
    self.attemptToLogin = NO;
    NSLog(@"Logging in to meteor");
    [self.meteorClient logonWithUsername:self.email.text password:self.password.text responseCallback:^(NSDictionary *response, NSError *error) {
      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
      if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
      }
      [self performSegueWithIdentifier:@"ContactsListSegue" sender:nil];
    }];
  }
}

@end
