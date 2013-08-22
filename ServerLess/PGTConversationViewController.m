//
//  PGTConversationViewController.m
//  ServerLess
//
//  Created by Gilot, Pierre on 7/19/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTConversationViewController.h"
#import "Constants.h"
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import <AWSS3/AWSS3.h>
#import "PGTLoginViewController.h"
#import "PGTConversationCell.h"
#import "PGTConversationMetadata.h"
#import "PGTMessage.h"
#import "PGTConversation.h"

#define PGT_EXTENSION @"sls"

@interface PGTConversationViewController ()
@property (nonatomic, strong) NSMutableArray* conversations;
@property (nonatomic, strong) NSURL* localRoot;
- (NSURL *)getDocURL:(NSString *)filename;
- (void)loadDocAtURL:(NSURL *)fileURL;
@end

@implementation PGTConversationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.conversations = [[NSMutableArray alloc] initWithCapacity:10];
    [self registerForKeyboardNotifications];
    
    [[AmazonClientManager sharedInstance] reloadFBSession];
    
    

}

-(void)viewDidAppear:(BOOL)animated
{
    // See if the app has a valid token for the current state.
    if ([AmazonClientManager sharedInstance].isLoggedIn) {
        // To-do, show logged in view
        AMZLogDebug(@"Logged In!");
        //[self refresh];
    } else {
        // No, display the login page.
        //[self showLoginView];
        AMZLogDebug(@"Not Logged In!");
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Application methods
-(void)old_refresh
{
    if (![AmazonClientManager sharedInstance].isLoggedIn)
        return;

    AMZLogDebug(@"");
}


- (void)loadLocal {
    AMZLogDebug(@"");
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    AMZLogDebug(@"Found %d local files.", localDocuments.count);
    for (int i=0; i < localDocuments.count; i++) {
        
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        if ([[fileURL pathExtension] isEqualToString:PGT_EXTENSION]) {
            AMZLogDebug(@"Found local file: %@", fileURL);
            [self loadDocAtURL:fileURL];
        }
    }
    
    //self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)refresh {
    
    if (![AmazonClientManager sharedInstance].isLoggedIn)
        return;

    [_conversations removeAllObjects];
    [_conversationsTable reloadData];
    
    [self loadLocal];
}

-(IBAction)sendButtonPressed:(id)sender
{
    [_messageField endEditing:YES];
    AMZLogDebug(@"Sending text: %@", _messageField.text);
    
    PGTMessage* message = [[PGTMessage alloc] init];
    message.text = _messageField.text;
    message.type = kMessageTypeText;
    message.id = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    message.from = [AmazonClientManager sharedInstance].profileID;
    message.to = [AmazonClientManager sharedInstance].profileID;

    [message send];
    
    _messageField.text = @"";
}

-(IBAction)addFriendButtonPressed:(id)sender
{
    AMZLogDebug(@"");
    
    // Initialize the friend picker
    FBFriendPickerViewController *friendPickerController =
    [[FBFriendPickerViewController alloc] init];
    // Set the friend picker title
    friendPickerController.title = @"Pick Friends";
    friendPickerController.session = [AmazonClientManager sharedInstance].session;
    friendPickerController.delegate = self;
    
    // TODO: Set up the delegate to handle picker callbacks, ex: Done/Cancel button
    
    // Load the friend data
    [friendPickerController loadData];
    // Show the picker modally
    [friendPickerController presentModallyFromViewController:self animated:YES handler:nil];
}


#pragma mark - PGTLoginViewController Delegate methods
-(void)loginControllerDidLoginSuccessfully:(PGTLoginViewController *)controller
{
    AMZLogDebug(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self refresh];
    //[_conversationsTable reloadData];
}

-(void)loginControllerDidNotLogin:(PGTLoginViewController *)controller withError:(NSString *)message
{
    AMZLogDebug(@"");
}

#pragma mark - Segue Operations
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLogin"])
    {
        PGTLoginViewController* loginController = [segue destinationViewController];
        loginController.delegate = self;
    }
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    AMZLogDebug(@"");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    AMZLogDebug(@"");
    [self sendButtonPressed:self];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AMZLogDebug(@"");
    [textField resignFirstResponder];
}

#pragma mark - keyboard notifications
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y -= kbSize.height;
    [self.view setFrame:frame];
    [UIView commitAnimations];
    
    /*
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
     */
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y += kbSize.height;
    [self.view setFrame:frame];
    [UIView commitAnimations];
//
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITableView Datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    if (tableView == _conversationsTable)
        return _conversations.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _conversationsTable) {
        PGTConversationCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell"];

        cell.thumb.profileID = @"100000110502374"; //[AmazonClientManager sharedInstance].profileID;
//        cell.thumb.profileID = [[[self.conversations objectAtIndex:[indexPath row]] friendAtIndex:0] objectForKey:@"id"];
        AMZLogDebug(@"conversation: %@", [self.conversations objectAtIndex:[indexPath row]]);
        AMZLogDebug(@"conversation friends: %@", [[self.conversations objectAtIndex:[indexPath row]] friends]);
        //[cell setConversation:[self.conversations objectAtIndex:[indexPath row]]];
        return cell;
    }
    return nil;
}

#pragma mark - UITableView Delegate methods

#pragma mark - File Handling
- (NSURL *)localRoot {
    if (_localRoot != nil) {
        return _localRoot;
    }
    
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    _localRoot = [paths objectAtIndex:0];
    return _localRoot;
}

- (NSURL *)getDocURL:(NSString *)filename {
    return [self.localRoot URLByAppendingPathComponent:filename];
}

- (void)insertNewConversation:(id)sender
{
    
    // Determine a unique filename to create
    NSURL * fileURL = [self getDocURL:[NSString stringWithFormat:@"conversation.%@",PGT_EXTENSION]];
    NSLog(@"Want to create file at %@", fileURL);
    
    // Create new document and save to the filename
    PGTConversation * doc = [[PGTConversation alloc] initWithFileURL:fileURL];
    [doc saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
        if (!success) {
            NSLog(@"Failed to create file at %@", fileURL);
            return;
        }
        
        NSLog(@"File created at %@", fileURL);
//        PTKMetadata * metadata = doc.metadata;
//        NSURL * fileURL = doc.fileURL;
//        UIDocumentState state = doc.documentState;
//        NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
//        
//        // Add on the main thread and perform the segue
//        _selDocument = doc;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self addOrUpdateEntryWithURL:fileURL metadata:metadata state:state version:version];
//            [self performSegueWithIdentifier:@"showDetail" sender:self];
//        });
        
    }]; 
}

- (void)loadDocAtURL:(NSURL *)fileURL {
    AMZLogDebug(@"");
    // Open doc so we can read metadata
    PGTConversation * doc = [[PGTConversation alloc] initWithFileURL:fileURL];
    [doc openWithCompletionHandler:^(BOOL success) {
        
        // Check status
        if (!success) {
            NSLog(@"Failed to open %@", fileURL);
            return;
        }
        
        // Preload metadata on background thread
        PGTConversationMetadata * metadata = doc.metadata;
        NSURL * fileURL = doc.fileURL;
        UIDocumentState state = doc.documentState;
        NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        NSLog(@"Loaded File URL: %@", [doc.fileURL lastPathComponent]);
        
        // Close since we're done with it
        [doc closeWithCompletionHandler:^(BOOL success) {
            
            // Check status
            if (!success) {
                NSLog(@"Failed to close %@", fileURL);
                // Continue anyway...
            }
            
            // Add to the list of files on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOrUpdateEntryWithID:metadata.id metadata:metadata state:state version:version];
            });
        }];             
    }];
    
}
#pragma mark Entry management methods

- (int)indexOfEntryWithID:(NSString *)conversationID {
    __block int retval = -1;
    [_conversations enumerateObjectsUsingBlock:^(PGTConversationMetadata * entry, NSUInteger idx, BOOL *stop) {
        if ([entry.id isEqual:conversationID]) {
            retval = idx;
            *stop = YES;
        }
    }];
    return retval;
}

- (void)addOrUpdateEntryWithID:(NSString *)conversationID metadata:(PGTConversationMetadata *)metadata state:(UIDocumentState)state version:(NSFileVersion *)version {
    
    int index = [self indexOfEntryWithID:conversationID];
    
    // Not found, so add
    if (index == -1) {
        
        //PTKEntry * entry = [[PTKEntry alloc] initWithFileURL:fileURL metadata:metadata state:state version:version];
        
        [self.conversations addObject:metadata];
        [self.conversationsTable  insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(self.conversations.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        
    }
    
    // Found, so edit
    else {
        
//        PTKEntry * entry = [_objects objectAtIndex:index];
//        entry.metadata = metadata;
//        entry.state = state;
//        entry.version = version;
        
        [self.conversationsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}

#pragma mark - FBFriendPickerDelegate delegate methods
/*
 * Event: Done button clicked
 */
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    FBFriendPickerViewController *friendPickerController =
    (FBFriendPickerViewController*)sender;
    NSLog(@"Selected friends: %@", friendPickerController.selection);
    
    FBGraphObject* friend = [friendPickerController.selection objectAtIndex:0];
    AMZLogDebug(@"selected id: %@", [friend objectForKey:@"id"] );
    
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    BOOL found=NO;
    NSUInteger index = 0;
    for (PGTConversationMetadata* meta in _conversations) {
        if ([meta hasFriendWithID:[friend objectForKey:@"id"]]) {
            found = YES;
            break;
        }
        index++;
    }
    
    if (found) {
        // NOP
    } else {
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.%@", [self localRoot], [[NSUUID UUID] UUIDString], PGT_EXTENSION ]];
        
        AMZLogDebug(@"creating file: %@", url);
        
        PGTConversation* newConversation = [[PGTConversation alloc] initWithFileURL:url];
        newConversation.metadata.description = [friend objectForKey:@"name"];
        [newConversation.metadata addFriend:friend];
        [newConversation saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            AMZLogDebug(@"Document saved %@", (success?@"successfully":@"with error"));
        }];
        //PGTConversationMetadata* meta = [[PGTConversationMetadata alloc] init];
        //meta.id = [friend objectForKey:@"id"];
        //meta.description = [friend objectForKey:@"name"];
        //[_conversations addObject:meta];
        //index = _conversations.count-1;
        //[_conversationsTable reloadData];
        [self addOrUpdateEntryWithID:newConversation.metadata.id metadata:newConversation.metadata state:newConversation.documentState version:nil];
    }
    //[_conversationsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
    
    // Dismiss the friend picker
//    [[sender presentingViewController] dismissModalViewControllerAnimated:YES];
}

/*
 * Event: Cancel button clicked
 */
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"Canceled");
    // Dismiss the friend picker
    [[sender presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}
@end
