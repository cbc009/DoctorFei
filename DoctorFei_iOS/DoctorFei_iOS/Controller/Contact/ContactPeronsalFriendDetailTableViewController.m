//
//  ContactPeronsalFriendDetailTableViewController.m
//  DoctorFei_iOS
//
//  Created by GuJunjia on 15/3/15.
//
//

#import "ContactPeronsalFriendDetailTableViewController.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "UserAPI.h"
#import "DoctorAPI.h"
#import "ContactPersonalDetailInfoViewController.h"
@interface ContactPeronsalFriendDetailTableViewController ()
- (IBAction)backButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToContactButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
- (IBAction)addToContactButtonClicked:(id)sender;

@end

@implementation ContactPeronsalFriendDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.sendMessageButton setHidden:(_mode == ContactPersonalFriendDetailModeNormal)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self reloadUIView];
    [self fetchMemberInfo];
    [self checkFriend];
    
    CGRect footerRect = self.tableView.tableFooterView.frame;
    footerRect.size.height = 100.0f;
    [self.tableView.tableFooterView setFrame:footerRect];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadUIView {
    if (_currentFriend.icon && _currentFriend.icon.length > 0) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentFriend.icon] placeholderImage:[UIImage imageNamed:@"details_uers_example_pic"]];
    }
    [self.nameLabel setText:_currentFriend.realname];
    [self.genderLabel setText:_currentFriend.gender.intValue ? @"男" : @"女"];
    [self.phoneLabel setText:_currentFriend.mobile];
    [self.addToContactButton setHidden:[_currentFriend.isFriend boolValue]];
//    NSLog(@"%@",_currentFriend.isFriend);
    
}
- (void)checkFriend {
    NSDictionary *param = @{
                            @"myuserid": [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],
                            @"myusertype": @0,
                            @"userid": _currentFriend.userId,
                            @"usertype": _currentFriend.userType
                            };
    [UserAPI checkFriendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        _currentFriend.isFriend = @([dataDict[@"friend"] intValue] > 0 ? YES : NO);
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUIView];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}

- (void)fetchMemberInfo {
    NSDictionary *param = @{@"userid": _currentFriend.userId};
    [UserAPI getMemberInfomationWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dataDict = [responseObject firstObject];
        _currentFriend.icon = dataDict[@"icon"];
        _currentFriend.realname = dataDict[@"RealName"];
        _currentFriend.gender = @([dataDict[@"Gender"]intValue]);
        _currentFriend.mobile = dataDict[@"Mobile"];
        _currentFriend.noteName = dataDict[@"notename"];
        _currentFriend.situation = dataDict[@"describe"];
        _currentFriend.email = dataDict[@"Email"];
        _currentFriend.hospital = dataDict[@"hospital"];
        _currentFriend.department = dataDict[@"department"];
        _currentFriend.jobTitle = dataDict[@"jobTitle"];
        _currentFriend.otherContact = dataDict[@"OtherContact"];
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUIView];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
    
}

- (void)addFriend{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSDictionary *params = @{
                             @"usertype": _currentFriend.userType,
                             @"doctorid": [userId stringValue],
                             @"friendid": _currentFriend.userId
                             };
    [DoctorAPI addFriendWithParameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [responseObject firstObject];
        if ([dic[@"state"] integerValue]==1) {
            UIImageView *completeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_prompt-01_pic.png"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.dimBackground = YES;
            hud.customView = completeImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.addToContactButton setEnabled: NO];
            });
        }
        else{
            hud.mode = MBProgressHUDModeText;
        }
        hud.detailsLabelText = dic[@"msg"];//NSLocalizedString(@"好友添加成功", nil);
        [hud hide:YES afterDelay:1.0f];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"错误";
        hud.detailsLabelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5f];
    }];
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ContactPersonalDetailInfoViewController *vc = [segue destinationViewController];
    vc.currentFriend = self.currentFriend;
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addToContactButtonClicked:(id)sender {
    [self addFriend];
}
@end
