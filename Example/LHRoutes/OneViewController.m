//
//  LHViewController.m
//  Router
//
//  Created by 李辉 on 2022/3/20.
//

#import "OneViewController.h"
#import "LHRouter.h"

@interface OneViewController ()
@property (nonatomic, strong) UIButton *jumpButton;
@property (nonatomic, strong) UIButton *serviceButton;
@property (nonatomic, strong) UILabel *label;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.jumpButton.frame = CGRectMake(50, 100, 100, 50);
    self.jumpButton.backgroundColor = [UIColor redColor];
    
    self.serviceButton.frame = CGRectMake(200, 100, 100, 50);
    self.serviceButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.jumpButton];
    [self.view addSubview:self.serviceButton];
    
    self.label.frame = CGRectMake(100, 200, 150, 100);
    self.label.text = @"1 + 2 = ?";
    [self.view addSubview:self.label];
}

- (void)jumpButtonAction {
    UIView *v =[[UIView alloc] initWithFrame:CGRectMake(200, 200, 100, 100)];
    v.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:v];
    CGRect r = CGRectMake(0, 0, 0, 0);
    [ @(r) CGRectValue];
    NSDictionary *params = @{@"name":@"设置"};
    NSURL *URL = [NSURL URLWithString:@"lh://jump.vc.lhrouter/TwoViewController/?#push"];
    [LHRouter openURL:URL withParams:params];
    
}

- (void)serviceButtonAction{
    NSURL *URL = [NSURL URLWithString:@"lh://call.service.lhrouter/LHTestService/sum:b:"];
    NSDictionary *params = @{@"1":@(1),@"2":@(2)};
    __weak typeof(self)weakSelf = self;
    
    [LHRouter openURL:URL withParams:params callBack:^(NSString *pathComponentKey, id obj, id returnValue) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.label.text = [NSString stringWithFormat:@"1 + 2 = %d", [returnValue intValue]];
    }];
}

-(UIButton *)jumpButton {
    if (_jumpButton == nil) {
        _jumpButton = [[UIButton alloc] init];
        [_jumpButton addTarget:self action:@selector(jumpButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_jumpButton setTitle:@"路由跳转" forState:(UIControlStateNormal)];
        [_jumpButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    }
    return _jumpButton;
}

-(UIButton *)serviceButton {
    if (_serviceButton == nil) {
        _serviceButton = [[UIButton alloc] init];
        [_serviceButton addTarget:self action:@selector(serviceButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_serviceButton setTitle:@"服务通信" forState:(UIControlStateNormal)];
        [_serviceButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    }
    return _serviceButton;
}

-(UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor lightGrayColor];
        _label.font = [UIFont systemFontOfSize:20 weight:(UIFontWeightMedium)];
    }
    return _label;
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
