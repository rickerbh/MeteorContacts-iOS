//
//  HJRContactListTableViewController.m
//  Meteor Contacts
//
//  Created by Hamish Rickerby on 25/03/2014.
//  Copyright (c) 2014 happtic consulting. All rights reserved.
//

#import "HJRContactListTableViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <ObjectiveDDP/MeteorClient.h>

@interface HJRContactListTableViewController ()
@property (nonatomic, strong) NSArray *contacts;
@end

@implementation HJRContactListTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.contacts = @[];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReceiveAddedNotification:)
                                               name:@"contacts_added"
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReceiveRemovedNotification:)
                                               name:@"contacts_removed"
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReceiveChangedNotification:)
                                               name:@"contacts_changed"
                                             object:nil];

  // Subscribe to the contacts collection via the server my-contacts publishing mechanism
  [self.meteorClient addSubscription:@"my-contacts"];
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_removed" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_changed" object:nil];
}

#pragma mark - HJRContactCellDelegate conformance

- (void)contactCell:(HJRContactCell *)cell didTapSendEmailTo:(NSString *)emailAddress {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:@[emailAddress]];
    [controller setSubject:@"Sent from happtic contacts"];
    [controller setMessageBody:@"Hello there" isHTML:NO];
    if (controller) {
      [self presentViewController:controller animated:YES completion:^{}];
    }
  }
}

- (void)contactCell:(HJRContactCell *)cell didTapPhone:(NSString *)number {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]]];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UITableViewDataSource conformance

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  HJRContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
  NSDictionary *contact = self.contacts[indexPath.row];
  cell.name.text = contact[@"name"];
  cell.email = contact[@"email"];
  cell.phone = contact[@"phone"];
  return cell;
}

 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Deleting..."];
    NSDictionary *contact = self.contacts[indexPath.row];
    [self.meteorClient callMethodName:@"deleteContactServer" parameters:@[contact[@"_id"]] responseCallback:^(NSDictionary *response, NSError *error) {
      NSLog(@"Error: %@", error);
      NSLog(@"Response: %@", response);
     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
      [self.tableView reloadData];
    }];
  }
}

#pragma mark - Meteor Notfications

- (void)didReceiveAddedNotification:(NSNotification *)aNotification {
  NSLog(@"added %@", aNotification);
  self.contacts = [self.contacts arrayByAddingObject:aNotification.userInfo];
  [self.tableView reloadData];
}

- (void)didReceiveRemovedNotification:(NSNotification *)aNotification {
  NSLog(@"removed %@", aNotification);
  NSString *removedObjectID = aNotification.userInfo[@"_id"];
  __block NSInteger myObjectIndex = -1;
  [self.contacts enumerateObjectsUsingBlock:^(NSDictionary *contact, NSUInteger idx, BOOL *stop){
    if ([contact[@"_id"] isEqualToString:removedObjectID]) {
      myObjectIndex = idx;
      *stop = YES;
    }
  }];
  if (myObjectIndex != -1) {
    NSMutableArray *tempContacts = [self.contacts mutableCopy];
    [tempContacts removeObjectAtIndex:myObjectIndex];
    self.contacts = tempContacts;
  }
  [self.tableView reloadData];
}

- (void)didReceiveChangedNotification:(NSNotification *)aNotification {
  NSLog(@"changed %@", aNotification);
  NSString *removedObjectID = aNotification.userInfo[@"_id"];
  __block NSInteger myObjectIndex = -1;
  [self.contacts enumerateObjectsUsingBlock:^(NSDictionary *contact, NSUInteger idx, BOOL *stop){
    if ([contact[@"_id"] isEqualToString:removedObjectID]) {
      myObjectIndex = idx;
      *stop = YES;
    }
  }];
  if (myObjectIndex != -1) {
    NSMutableArray *tempContacts = [self.contacts mutableCopy];
    [tempContacts removeObjectAtIndex:myObjectIndex];
    [tempContacts insertObject:aNotification.userInfo atIndex:myObjectIndex];
    self.contacts = tempContacts;
  }
  [self.tableView reloadData];
}


@end
