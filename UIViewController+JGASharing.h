//
//  UIViewController+JGASharing.h
//  wordstowellness
//
//  Created by John Grant on 12-03-31.
//  Copyright (c) 2012 JGApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Twitter/Twitter.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface UIViewController(JGASharing) <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

// Display the built in in iOS5 tweet sheet with the provided initial text (optional) and link (optional)
- (void)displayTweetSheetWithText:(NSString *)text link:(NSString *)link;

// Opens an SMS window with the provided text
-(void)displayTextSheetWithText:(NSString *)text;

// Opens an email window with the given body and subject
- (void)displayMailSheetWithBody:(NSString *)body subject:(NSString *)subject;
@end
