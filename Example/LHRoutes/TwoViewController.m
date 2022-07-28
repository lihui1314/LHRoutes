//
//  TwoViewController.m
//  Router
//
//  Created by 李辉 on 2022/3/20.
//

#import "TwoViewController.h"
#import "LHRDefines.h"

LHR_PAGE_EXPORT(towViewPage, TwoViewController)
@interface TwoViewController ()
@property (nonatomic, copy) NSString *name;

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    self.title = self.name;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
