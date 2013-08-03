//
//  PGTMessagesViewController.m
//  ServerLess
//
//  Created by Gilot, Pierre on 6/28/13.
//  Copyright (c) 2013 Gilot, Pierre. All rights reserved.
//

#import "PGTMessagesViewController.h"
#import "Constants.h"
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"
#import <AWSS3/AWSS3.h>
#import "PGTLoginViewController.h"

#import "PGTMessage.h"

@interface PGTMessagesViewController ()
@property (atomic, strong) NSMutableArray* objects;
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong) NSString* prefix;
@property (nonatomic, strong) UIView* search;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NSArray* selectedFriends;
@end

@implementation PGTMessagesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.objects = [[NSMutableArray alloc] initWithCapacity:25];
        self.prefix = [AmazonKeyChainWrapper username];
        self.bucket = BUCKET_NAME;
    }
    return self;
}

-(void)refresh
{
    @try {
        if (!_prefix) {
            self.prefix = [AmazonKeyChainWrapper username];
        }
        
        if (!_bucket) {
            self.bucket = BUCKET_NAME;
        }
        
        S3ListObjectsRequest  *listObjectRequest = [[S3ListObjectsRequest alloc] initWithName:self.bucket] ;
        listObjectRequest.prefix = [NSString stringWithFormat:@"%@/", _prefix];
        
        S3ListObjectsResponse *listObjectResponse = [[[AmazonClientManager sharedInstance] s3] listObjects:listObjectRequest];
        S3ListObjectsResult   *listObjectsResults = listObjectResponse.listObjectsResult;
        
        
        if (_objects == nil) {
            self.objects = [[NSMutableArray alloc] initWithCapacity:[listObjectsResults.objectSummaries count]];
        }
        else {
            [_objects removeAllObjects];
        }
        for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
            [_objects addObject:[objectSummary key]];
            NSLog(@"Summary : %@", objectSummary.etag);
        }
        [_objects sortUsingSelector:@selector(compare:)];
    }
    @catch (AmazonClientException *exception)
    {
        NSLog(@"Exception = %@", exception);
        [[Constants errorAlert:[NSString stringWithFormat:@"Error list objects: %@", exception.message]] show];
    }
    
    [self.tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated
{
    // See if the app has a valid token for the current state.
    if ([AmazonClientManager sharedInstance].isLoggedIn) {
        // To-do, show logged in view
        AMZLogDebug(@"Logged In!");
        [self refresh];
    } else {
        // No, display the login page.
        //[self showLoginView];
        AMZLogDebug(@"Not Logged In!");
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)viewDidLoad
{
    AMZLogDebug(@"");
    [super viewDidLoad];

    //[AmazonClientManager sharedInstance].delegate = self;
    [[AmazonClientManager sharedInstance] reloadFBSession];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.search = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [self.view addSubview:_search];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
    
    // Configure the cell...
    NSString *fullObjectName = [_objects objectAtIndex:indexPath.row];
    NSRange range = [fullObjectName rangeOfString:[AmazonKeyChainWrapper username]];
    NSString *prunedName = [fullObjectName substringFromIndex:(range.location+ range.length + 1)];
    
    cell.textLabel.text                      = prunedName;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSLog(@"hey");
    if (!self.friendPickerController) {
        self.friendPickerController = [[FBFriendPickerViewController alloc]
                                       initWithNibName:nil bundle:nil];
        self.friendPickerController.title = @"Select friends";
        _friendPickerController.session = [[AmazonClientManager sharedInstance] session];
    }
    
    [self.friendPickerController loadData];

    [self.navigationController pushViewController:self.friendPickerController
                                         animated:true];
    _friendPickerController.delegate = self;
    [self presentViewController:_friendPickerController animated:YES completion:nil];
}


#pragma mark - UISearchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search text: %@", searchBar.text);
    
    PGTMessage* message = [[PGTMessage alloc] init];
    message.text = searchBar.text;
    message.type = kMessageTypeText;
    message.id = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    searchBar.text = @"";
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:message forKey:@"message_data"];
    [archiver finishEncoding];
    
    @try {
        NSString *keyName = [NSString stringWithFormat:@"%@/%@", [AmazonKeyChainWrapper username], message.id];
        
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:keyName inBucket:self.bucket] ;
        por.data = data;
        por.storageClass = @"REDUCED_REDUNDANCY";
        por.contentType = @"application/x-plist; charset=utf-8";
        
        [[[AmazonClientManager sharedInstance] s3] putObject:por];
    }
    @catch (AmazonClientException *exception)
    {
        NSLog(@"Exception = %@", exception);
        [[Constants errorAlert:[NSString stringWithFormat:@"Error adding object: %@", exception.message]] show];
    }

    
    
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - FB delegates
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    self.selectedFriends = friendPicker.selection;
    //    [self updateSelections];
    NSLog(@"selection detail: %@", [_selectedFriends objectAtIndex:0]);
}

#pragma mark - PGTLoginViewController Delegate methods
-(void)loginControllerDidLoginSuccessfully:(PGTLoginViewController *)controller
{
    AMZLogDebug(@"");
    [self dismissViewControllerAnimated:YES completion:nil];
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
@end
