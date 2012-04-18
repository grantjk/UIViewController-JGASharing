//
//  UIViewController+JGASharing.m
//  wordstowellness
//
//  Created by John Grant on 12-03-31.
//  Copyright (c) 2012 JGApps. All rights reserved.
//

#import "UIViewController+JGASharing.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController(JGASharing)

- (void)displayTweetSheetWithText:(NSString *)text link:(NSString *)link photo:(UIImage *)image
{
  if ([TWTweetComposeViewController canSendTweet]) {
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];        
    
    if (text) [tweetSheet setInitialText:text];
    if (link) [tweetSheet addURL:[NSURL URLWithString:link]];
    if (image) [tweetSheet addImage:image];
      
      tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
          [self cleanUpAfterSharing];
          [self dismissModalViewControllerAnimated:YES];
      };
      
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
- (void)displayMailSheetWithBody:(NSString *)body subject:(NSString *)subject attachment:(NSString *)filePath
{
  MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
  picker.mailComposeDelegate = self;
  [picker setSubject:subject];
  [picker setMessageBody:body isHTML:NO];
    
    if (filePath) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [picker addAttachmentData:data mimeType:@"image/png" fileName:filePath];
    }
    
    
  [self presentViewController:picker animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{	    
    [self cleanUpAfterSharing];
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cleanUpAfterSharing
{
    // To be overriden
}

- (UIImage *)createPNGfromUIView:(UIView*)aView{
    UIGraphicsBeginImageContext(aView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [aView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSString *)savePNGfromUIView:(UIView*)aView withFileName:(NSString*)aFilename{
    UIGraphicsBeginImageContext(aView.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [aView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",aFilename]];
    
    // instructs the mutable data object to write its context to a file on disk
    NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    [data writeToFile:documentDirectoryFilename atomically:YES];
    return documentDirectoryFilename;
}


@end
