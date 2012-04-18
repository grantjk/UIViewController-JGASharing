//
//  UIViewController+JGASharing.m
//  wordstowellness
//
//  Created by John Grant on 12-03-31.
//  Copyright (c) 2012 JGApps. All rights reserved.
//

#import "UIViewController+JGASharing.h"

@implementation UIViewController(JGASharing)

- (void)displayTweetSheetWithText:(NSString *)text link:(NSString *)link photo:(UIImage *)image
{
  if ([TWTweetComposeViewController canSendTweet]) {
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];        
    
    if (text) [tweetSheet setInitialText:text];
    if (link) [tweetSheet addURL:[NSURL URLWithString:link]];
    if (image) [tweetSheet addImage:image];
      
    [self presentViewController:tweetSheet animated:YES completion:NULL];
  }else{
      NSString *errorMessage = @"Please enable Twitter in Settings to use this feature";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:errorMessage
                                                   delegate:nil 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles: nil];
    [alert show];
  }    
}
- (void)displayTextSheetWithText:(NSString *)text
{
  if ([MFMessageComposeViewController canSendText]){
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    vc.messageComposeDelegate = self;
    [vc setBody:text];
    [self presentViewController:vc animated:YES completion:NULL];
  }else{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Unable to send SMS from this device." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles: nil];
    [alert show];
  }
}
- (void)displayMailSheetWithBody:(NSString *)body subject:(NSString *)subject
{
  MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
  picker.mailComposeDelegate = self;
  [picker setSubject:subject];
  [picker setMessageBody:body isHTML:NO];
  [self presentViewController:picker animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{	    
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
