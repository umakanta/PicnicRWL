//
//  ViewController.m
//  PicnicRWL
//
//  Created by Umakanta on 17/02/14.
//  Copyright (c) 2014 THBS. All rights reserved.
//

#import "ViewController.h"
// At top of file
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController (){
    
    bool bugDead;
}

@property (weak, nonatomic) IBOutlet UIImageView *basketTop;
@property (weak, nonatomic) IBOutlet UIImageView *basketBottom;


@property (nonatomic,weak) IBOutlet UIImageView *napkinTop;
@property (nonatomic,weak) IBOutlet UIImageView *napkinBottom;

@property (weak, nonatomic) IBOutlet UIImageView *bug;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CGRect basketTopFrame = self.basketTop.frame;
    basketTopFrame.origin.y = -basketTopFrame.size.height+30;
    
    CGRect basketBottomFrame = self.basketBottom.frame;
    basketBottomFrame.origin.y = self.view.bounds.size.height-30;
    
    /* ------------ before ios4 -------------
    [UIView beginAnimations:@"picnicAnimation" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.basketTop.frame = basketTopFrame;
    self.basketBottom.frame = basketBottomFrame;
    
     */
    
    /* ------------ ios4+  -------------*/
    
    [UIView animateWithDuration:1.0 delay:1.0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.basketTop.frame = basketTopFrame;
        self.basketBottom.frame = basketBottomFrame;

    } completion:^(BOOL finished) {
        NSLog(@"Done!");
    }];
    
    
    
    
    
     // For Napkin's imageView --------
    
    CGRect napkinTopFrame = self.napkinTop.frame;
    napkinTopFrame.origin.y = -napkinTopFrame.size.height;
    CGRect napkinBottomFrame = self.napkinBottom.frame;
    napkinBottomFrame.origin.y = self.view.bounds.size.height;
    
    [UIView animateWithDuration:1
                          delay:1.3
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.napkinTop.frame = napkinTopFrame;
                         self.napkinBottom.frame = napkinBottomFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done Napkin!");
                     }];
    
    
    // Launch the chain of the bug animation at the bottom of viewDidAppear
    [self moveToLeft:nil finished:nil context:nil];
    
    
}

-(void)moveToLeft:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
 
    if (bugDead) return;
    
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options:(UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction) animations:^{
        if (bugDead) return;
                            
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(faceRight:finished:context:)];
        self.bug.center = CGPointMake(75, 200);
        
    } completion:^(BOOL finished) {
        NSLog(@"Move to left done");
    }];
    
}

-(void)faceRight:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{

    if (bugDead) return;
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction) animations:^{
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(moveToRight:finished:context:)];
        self.bug.transform = CGAffineTransformMakeRotation(M_PI);
        
    } completion:^(BOOL finished) {
        
        NSLog(@"Face right done");
    }];

}

- (void)moveToRight:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if (bugDead) return;
    
    [UIView animateWithDuration:1.0
                          delay:1.0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         if (bugDead) return;
                         
                         [UIView setAnimationDelegate:self];
                         [UIView setAnimationDidStopSelector:@selector(faceLeft:finished:context:)];
                         self.bug.center = CGPointMake(230, 250);
                         
                     }
                     completion:^(BOOL finished){
                         
                         NSLog(@"Move to right done");
                     }];
    
}

- (void)faceLeft:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if (bugDead) return;
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [UIView setAnimationDelegate:self];
                         
                         [UIView setAnimationDidStopSelector:@selector(moveToLeft:finished:context:)];
                         self.bug.transform = CGAffineTransformMakeRotation(0);
                         
                         
                     }completion:^(BOOL finished){
                         NSLog(@"Face left done");
                         
                     }];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    //CGRect bugRect = [self.bug frame];
    CGRect bugRect = [[[self.bug layer] presentationLayer] frame];
    
    if (CGRectContainsPoint(bugRect, touchLocation)) {
        NSLog(@"Bug tapped!");
        bugDead = true;
        [UIView animateWithDuration:0.7
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.bug.transform = CGAffineTransformMakeScale(1.25, 0.75);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:1.0
                                                   delay:1.0
                                                 options:0
                                              animations:^{
                                                  self.bug.alpha = 0.0;
                                              } completion:^(BOOL finished) {
                                                  [self.bug removeFromSuperview];
                                              }];
                         }];
        
    } else {
        NSLog(@"Bug not tapped.");
        return;
    }
    
    
    NSString *squishPath = [[NSBundle mainBundle]pathForResource:@"squish" ofType:@"caf"];
    NSURL *squishUrl = [NSURL fileURLWithPath:squishPath];
    
    SystemSoundID squishSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)squishUrl, &squishSoundID);
    AudioServicesPlaySystemSound(squishSoundID);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
