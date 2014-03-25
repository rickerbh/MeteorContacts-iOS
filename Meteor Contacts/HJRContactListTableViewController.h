//
//  HJRContactListTableViewController.h
//  Meteor Contacts
//
//  Created by Hamish Rickerby on 25/03/2014.
//  Copyright (c) 2014 happtic consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJRContactCell.h"

@class MeteorClient;

@import MessageUI;

@interface HJRContactListTableViewController : UITableViewController <HJRContactDelgate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) MeteorClient *meteorClient;
@end
