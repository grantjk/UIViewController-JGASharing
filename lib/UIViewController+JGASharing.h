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

// Display the built in in iOS5 tweet sheet with the provided initial text (optional), link (optional) and photo (optional)
- (void)displayTweetSheetWithText:(NSString *)text link:(NSString *)link photo:(UIImage *)image;

// Opens an SMS window with the provided text
- (void)displayTextSheetWithText:(NSString *)text;

// Opens an email window with the given body and subject
- (void)displayMailSheetWithBody:(NSString *)body subject:(NSString *)subject attachment:(NSString *)filePath;

// Creates and saves a png for the given view. 
- (UIImage *)createPNGfromUIView:(UIView*)aView;

// Creates a png and saves to documents. Returns full filepath
- (NSString *)savePNGfromUIView:(UIView*)aView withFileName:(NSString*)aFilename;

// Allow for clean up. Overriden in view controller
- (void)cleanUpAfterSharing;
@end
