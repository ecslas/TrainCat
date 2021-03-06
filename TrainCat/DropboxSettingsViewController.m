//
//  DropboxTestViewController.m
//  TrainCat
//
//  Created by Alankar Misra on 14/02/13.
//
//

#import <Dropbox/Dropbox.h>
#import "Constants.h"
#import "DropboxSettingsViewController.h"
#import "DSDropbox.h"
#import "Toast+UIView.h"
#import "ViewWithToast.h"


@interface DropboxSettingsViewController ()
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIButton *btnRetry;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (assign, nonatomic) BOOL isFirstRun;

@end

@implementation DropboxSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteDropboxLinkAttempt:) name:kDropboxLinkAttemptComplete object:nil];
	self.view.backgroundColor = getBackgroundColor();
    ((ViewWithToast *)self.view).toastBackgroundColor = [UIColor redColor];
    self.isFirstRun = ![DSDropbox accountInfo];
    [self hideControls];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isFirstRun) {
        [self authenticateDropbox];            
    } else {
        DBAccountInfo *ai = [DSDropbox accountInfo];
        self.label.text = [NSString stringWithFormat:@"Linked with account %@ (%@)", ai.displayName, ai.email];
        self.btnChange.hidden = NO;
    }
}

- (void)authenticateDropbox {
    [DSDropbox linkWithDelegate:self];
}

-(void)hideControls {
    self.btnChange.hidden = YES;
    self.btnRetry.hidden = YES;
    self.label.text = @"";    
}

- (IBAction)didAskToAuthenticate {
    [self hideControls];
    [self authenticateDropbox];
}

-(void)didCompleteDropboxLinkAttempt:(NSNotification *)notification {
    NSLog(@"didCompleteDropboxLinkAttempt");
    NSObject *obj = [notification object];
    if(!obj) {
        self.label.text = @"Failed to authenticate Dropbox. Try again.";
        self.btnRetry.hidden = NO;
        ((ViewWithToast *)self.view).toastBackgroundColor = [UIColor redColor];
        [self.view makeToast:@"Failed to authenticate Dropbox." duration:3.0 position:@"top"];
    } else {
        // Display linked information
        DBAccount *account = [notification object];
        DBAccountInfo *ai = [account info];
        
        if(account.info) {
            self.label.text = [NSString stringWithFormat:@"Linked with account Dropbox Account %@\n(%@).", ai.displayName, ai.email];
        } else {
            // TODO: For some reason the first time round, the notification object / DBAccount info seems to be null
            // Check the API to see why this is happening. Not a major error so don't sweat it.
            self.label.text = [NSString stringWithFormat:@"Linked successfully with Dropbox Account."];
        }
        
        self.btnChange.hidden = NO;
        ((ViewWithToast *)self.view).toastBackgroundColor = [UIColor colorWithRed:204.0/255 green:213.0/255 blue:19.0/255 alpha:255.0];
        [self.view makeToast:@"Dropbox authenticated." duration:3.0 position:@"top"];
    }
}

- (IBAction)didClickGenerateRandomFileButton {
    NSString *randomPath = [[NSString alloc] initWithFormat:@"r%d.txt", arc4random()];
    [DSDropbox writeToFile:randomPath theString:@"Hallelujah! Our DropBox code works. But before we celebrate, we have much to do, such as running this task on a separate background thread so it doesn't lock up the application during network activity, check for success or failure of the synch and displaying activity status gear icons to show the user that network activity is in progress.\n\nNetwork activity is an unkind beast."];
}


@end
