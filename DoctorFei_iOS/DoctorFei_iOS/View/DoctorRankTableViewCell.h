//
//  DoctorRankTableViewCell.h
//  DoctorFei_iOS
//
//  Created by hxx on 1/8/15.
//
//

#import <UIKit/UIKit.h>

@interface DoctorRankTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *iconImage;
-(void)setDataDic:(NSDictionary *)dic;
@end
