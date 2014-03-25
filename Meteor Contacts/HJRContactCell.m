//
//  HJRContactCell.m
//  Meteor Contacts
//
//  Created by Hamish Rickerby on 25/03/2014.
//  Copyright (c) 2014 happtic consulting. All rights reserved.
//

#import "HJRContactCell.h"

@interface HJRContactCell ()
- (IBAction)phoneTapped:(id)sender;
- (IBAction)emailTapped:(id)sender;
@end

@implementation HJRContactCell

- (IBAction)phoneTapped:(id)sender {
  if ([self.delegate respondsToSelector:@selector(contactCell:didTapPhone:)]) {
    [self.delegate contactCell:self didTapPhone:self.phone];
  }
}

- (IBAction)emailTapped:(id)sender {
  if ([self.delegate respondsToSelector:@selector(contactCell:didTapSendEmailTo:)]) {
    [self.delegate contactCell:self didTapSendEmailTo:self.email];
  }
}

- (void)openURLString:(NSString *)url {
  if ([self.delegate respondsToSelector:@selector(contactCell:didTapSendEmailTo:)]) {
    [self.delegate contactCell:self didTapSendEmailTo:self.email];
  }
}

@end
