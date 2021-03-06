//
//  MainViewController.m
//  HeaderViewAndPageView
//
//  Created by su on 16/8/8.
//  Copyright © 2016年 susu. All rights reserved.
//

#import "WLPageViewController.h"
#import "WLSegmentContainerView.h"

#define kSelfViewH self.view.bounds.size.height - 20.0f
#define kSelfViewW self.view.bounds.size.width
#define kStateBarH 20.0f

@interface WLPageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) BOOL canScroll;//子滑动视图能否滑动
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;//seactionHeadView能否滑动tableView
@end

@implementation WLPageViewController

-(UITableView *)mainTableView
{
    if (_mainTableView == nil){
        _mainTableView= [[WLTouchTableTableView alloc]initWithFrame:CGRectMake(0,20.0f,kSelfViewW,kSelfViewH)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor whiteColor];
    
    }
    return _mainTableView;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (instancetype)initWithControllers:(NSArray *)viewControlers titles:(NSArray *)titles config:(WLPageViewConfigModel*)config
{
    self = [super init];
    if (self) {
        self.viewControllers = viewControlers;
        self.titles = titles;
        self.configModel = config;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (instancetype)initWithControllers:(NSArray *)viewControlers titles:(NSArray *)titles
{
    self = [super init];
    if (self) {
        self.viewControllers = viewControlers;
        self.titles = titles;
        self.configModel = [WLPageViewConfigModel new];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self WLSetUpSubviews];
    
}

-(void)WLSetUpSubviews{
    [self.view addSubview:self.mainTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WLAcceptMsg:) name:k_leaveTopNotice object:nil];

}

-(void)setWLtableHeadView:(UIView *)WLtableHeadView{
    _WLtableHeadView = WLtableHeadView;
    [self.mainTableView beginUpdates];
    [_mainTableView setTableHeaderView:_WLtableHeadView];
    [self.mainTableView endUpdates];
}

#pragma mark - 通知
-(void)WLAcceptMsg : (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - scrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
     /*
     **处理联动
     */
    
    //1.获取滚动视图y值的偏移量
    CGFloat tabOffsetY = [_mainTableView rectForSection:0].origin.y;//第一section 的原点
    CGFloat offsetY = scrollView.contentOffset.y;//contentoffset 在有headView在的情况下默认为 -headviewheight
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;

    if (offsetY >= tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    
    //2.滑动方向改变
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:k_goTopNotice object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }
    
    
    CGFloat headViewH = CGRectGetMaxY(self.mainTableView.tableHeaderView.frame);
    //处理头部视图缩放效果
    if(offsetY < - headViewH) {
        CGRect headBounds = self.WLtableHeadView.frame;
        headBounds.origin.y = offsetY ;
        headBounds.size.height =  -offsetY;
        headBounds.origin.y = offsetY;
        self.WLtableHeadView.frame = headBounds;
    }

}


#pragma marl - tableDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kSelfViewH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    WLSegmentContainerView * container = [[WLSegmentContainerView alloc]initWithFrame:CGRectMake(0, 0, kSelfViewW, kSelfViewH) Controllers:_viewControllers Titles:_titles withConfig:_configModel parentVc:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:container];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
