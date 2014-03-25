//
//  HJRContactCell.h
//  Meteor Contacts
//
//  Created by Hamish Rickerby on 25/03/2014.
//  Copyright (c) 2014 happtic consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HJRContactCell;

@protocol HJRContactDelgate <NSObject>
@optional
- (void)contactCell:(HJRContactCell *)cell didTapSendEmailTo:(NSString *)emailAddress;
- (void)contactCell:(HJRContactCell *)cell didTapPhone:(NSString *)number;
@end

@interface HJRContactCell : UITableViewCell
@property (nonatomic, weak) id<HJRContactDelgate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;

@end
