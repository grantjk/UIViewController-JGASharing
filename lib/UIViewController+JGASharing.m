//
//  UIViewController+JGASharing.m
//  wordstowellness
//
//  Created by John Grant on 12-03-31.
//  Copyright (c) 2012 JGApps. All rights reserved.
//

#import "UIViewController+JGASharing.h"
#import <QuartzCore/QuartzCore.h>
#import "JGALoadingView.h"

#define kOptsKeyText    @"text"
#define kOptsKeyLink    @"link"
#define kOptsKeyImage   @"image"
#define kOptsBody       @"body"
#define kOptsAttach     @"attach"
#define kOptsSubject    @"subject"

#define kTwitterError @"Please enable Twitter in Settings to use this feature"

@implementation UIViewController(JGASharing)

- (void)displayViewController:(UIViewController *)viewController
{
    [JGALoadingView hideLoadingView];
    [self presentViewController:viewController animated:YES completion:NULL];
}

- (void)cleanUpAfterSharing
{
    // To be overriden
}

#pragma mark - TWITTER
- (void)displayTweetSheetWithText:(NSString *)text link:(NSString *)link photo:(UIImage *)image
{
    if ([TWTweetComposeViewController canSendTweet]) {
        [JGALoadingView loadingViewInView:self.view withText:@"Composing..."];
        
        NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithCapacity:3];
        if (text)   [opts setObject:text forKey:kOptsKeyText];
        if (link)   [opts setObject:link forKey:kOptsKeyLink];
        if (image)  [opts setObject:image forKey:kOptsKeyImage];
        
        [self performSelectorInBackground:@selector(createTweetSheet:) withObject:opts]; 
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:kTwitterError
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles: nil];
        [alert show];
        [self cleanUpAfterSharing];
    }    
}
- (void)createTweetSheet:(NSDictionary *)opts
{     
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];        
    if ([opts objectForKey:kOptsKeyText]){
        [tweetSheet setInitialText:[opts objectForKey:kOptsKeyText]];   
    }
    if ([opts objectForKey:kOptsKeyLink]){
        [tweetSheet addURL:[NSURL URLWithString:[opts objectForKey:kOptsKeyLink]]];
    }
    if ([opts objectForKey:kOptsKeyImage]){
        [tweetSheet addImage:[opts objectForKey:kOptsKeyImage]];   
    }
    
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
        [self cleanUpAfterSharing];
        [self dismissModalViewControllerAnimated:YES];
    };
    [self performSelectorOnMainThread:@selector(displayViewController:) withObject:tweetSheet waitUntilDone:NO];
}

#pragma mark - SMS
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
      [self cleanUpAfterSharing];      
  }
}

#pragma mark - EMAIL
- (void)displayMailSheetWithBody:(NSString *)body subject:(NSString *)subject attachment:(NSString *)filePath
{
    [JGALoadingView loadingViewInView:self.view withText:@"Composing..."];
    NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithCapacity:3];
    if (body)       [opts setObject:body forKey:kOptsBody];
    if (subject)    [opts setObject:subject forKey:kOptsSubject];
    if (filePath)   [opts setObject:filePath forKey:kOptsAttach];    
    [self performSelectorInBackground:@selector(displayEmail:) withObject:opts];
}

- (void)displayEmail:(NSDictionary *)opts
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if ([opts objectForKey:kOptsSubject]) {
        [picker setSubject:[opts objectForKey:kOptsSubject]];
    }
    if ([opts objectForKey:kOptsBody]) {
        [picker setMessageBody:[opts objectForKey:kOptsBody] isHTML:NO];
    }
    NSString *filePath = [opts objectForKey:kOptsAttach];
    if (filePath) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [picker addAttachmentData:data mimeType:@"image/png" fileName:filePath];
    }    
    
    [self performSelectorOnMainThread:@selector(displayViewController:) withObject:picker waitUntilDone:NO];
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

#pragma mark - Image Creation
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
    
    return [self saveImage:image withFileName:aFilename];
}

- (NSString *)saveImage:(UIImage *)image withFileName:(NSString *)filename
{
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",filename]];
    
    // instructs the mutable data object to write its context to a file on disk
    NSData *data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    [data writeToFile:documentDirectoryFilename atomically:YES];
    return documentDirectoryFilename;    
}


@end
