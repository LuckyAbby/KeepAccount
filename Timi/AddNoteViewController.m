//
//  AddNoteViewController.m
//  Timi
//
//
//  Created by abby on 18/12/11.
//

#import "AddNoteViewController.h"
#import "TimiItemCollectionViewCell.h"

#import "TimiTableViewController.h"

static NSString *cellIdentifier = @"collectionViewCell";


@interface AddNoteViewController () 

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *itemNameArr;
@property (nonatomic, strong) NSArray *itemPicArr;


@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, strong) TimiItemCollectionViewCell *selectedCell;

//@property (nonatomic, strong) DismissTransition *dismissTransition;

@end

@implementation AddNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationItem];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.keyboardView];
    
   
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
////        _dismissTransition = [DismissTransition new];
//    }
//    return self;
//}

#pragma mark - navigationItem methods
- (void)initNavigationItem
{
    self.navigationItem.title = @"添加账目";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(popCurrentViewController)];
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(openCamera)];
    UIBarButtonItem *calenderItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_calender.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openCalender)];
    self.navigationItem.rightBarButtonItems = @[cameraItem, calenderItem];
}

- (void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openCamera
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"抱歉" message:@"该功能板块还未实现哟，敬请期待。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]; //UIAlertAction相当于一种封装了触发方法的选项按钮
    [alertView addAction:action];
//    [self.navigationController pushViewController:alertView animated:YES];
    [self presentViewController:alertView animated:YES completion:^{
        
    }];
}
- (void)openCalender
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"抱歉" message:@"该功能板块还未实现哟，敬请期待。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]; //UIAlertAction相当于一种封装了触发方法的选项按钮
    [alertView addAction:action];
    //    [self.navigationController pushViewController:alertView animated:YES];
    [self presentViewController:alertView animated:YES completion:^{
        
    }];
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemNameArr.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TimiItemCollectionViewCell *cell = [TimiItemCollectionViewCell createCell:collectionView cellForItemAtIndexPath:indexPath reuseIdentifier:cellIdentifier];
    cell.cellLabel.text = self.itemNameArr[indexPath.item];
    UIImage *image = [UIImage imageNamed:self.itemPicArr[indexPath.item]];
    [image setAccessibilityIdentifier:self.itemPicArr[indexPath.item]];
    cell.cellImage = image;
    return cell;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TimiItemCollectionViewCell *selectedCell = (TimiItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self configureAnimationObject:selectedCell];
    [self translateMovement];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self shrink];
}


#pragma mark - animaion 
- (void)translateMovement
{
    CABasicAnimation *leftUpAnimation = [[CABasicAnimation alloc] init];
    leftUpAnimation.duration = 0.3;
    leftUpAnimation.keyPath = @"position";
    leftUpAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.cellImageView.center.x-50, self.cellImageView.center.y-50)];
    leftUpAnimation.delegate = self;
    [leftUpAnimation setValue:@"first" forKey:@"leftUpAnimation"];
    [self.cellImageView.layer addAnimation:leftUpAnimation forKey:@"leftUpAnimation"];
}

- (void)BezierMovement
{
    //进行第二段动画
    CAKeyframeAnimation *bezierTranslateAnimation = [[CAKeyframeAnimation alloc] init];
    bezierTranslateAnimation.duration = 0.5;
    //先判断键盘的状态，再决定到哪个点
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.cellImageView.center.x-50, self.cellImageView.center.y-50)];
    CGPoint logoLocation;
    CGPoint imageLocation = self.keyboardView.contentLogo.center;

    //用这个方法可以直接转化在不同view之间的坐标！！！神奇！
    logoLocation = [self.collectionView convertPoint:imageLocation fromView:self.keyboardView];

    
    [path addQuadCurveToPoint:logoLocation controlPoint:logoLocation];
    bezierTranslateAnimation.keyPath = @"position";
    bezierTranslateAnimation.path = path.CGPath;
    bezierTranslateAnimation.delegate = self;

    [bezierTranslateAnimation setValue:@"second" forKey:@"bezierTranslateAnimation"];
    [self.cellImageView.layer addAnimation:bezierTranslateAnimation forKey:@"bezierTranslateAnimation"];

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    if ([[anim valueForKey:@"leftUpAnimation"] isEqualToString:@"first"])
    {
        [self BezierMovement];
    } else if ([[anim valueForKey:@"bezierTranslateAnimation"] isEqualToString:@"second"])
    {
        self.keyboardView.contentLogo.image = self.selectedCell.cellImage;
        self.keyboardView.contentLabel.text = self.selectedCell.cellLabel.text;
        [self.cellImageView removeFromSuperview];
    }
}



- (void)configureAnimationObject:(TimiItemCollectionViewCell *)selectedCell
{
    self.selectedCell = selectedCell;
    self.cellImageView.image = selectedCell.cellImage;
    self.cellImageView.frame = CGRectMake(selectedCell.frame.origin.x+selectedCell.cellPic.frame.origin.x,selectedCell.frame.origin.y+selectedCell.cellPic.frame.origin.y, 32, 32);
    [self.collectionView addSubview:self.cellImageView];
    
}





#pragma mark - ItemCompleteDelegate
- (void)finisCompletingItem:(NSString *)contentPic contentStr:(NSString *)contentStr totalCost:(double)cost timeStamp:(NSDate *)date
{
    
    CATransition* transition = [CATransition animation];
    transition.type = @"rippleEffect";//可更改为其他方式
    transition.subtype = kCATransitionFromBottom;//可更改为其他方式
    transition.duration=0.8;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];

    [self.delegate finisCompletingItem:contentPic contentStr:contentStr totalCost:cost timeStamp:[NSDate date]];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - keyboard expand/shrink
- (void)keyboardStatus
{
    if (self.keyboardView.isShrink) {
        [self expand];

    } else {
        [self shrink];
        }
}

- (void)expand {

    CGRect expandRect = CGRectMake(0, self.view.bounds.size.height-290, self.view.bounds.size.width, 290);
    [UIView animateWithDuration:0.5 animations:^{
        self.keyboardView.frame = expandRect;
    } completion:^(BOOL finished) {
        self.keyboardView.isShrink = false;
    }];

}

- (void)shrink {
    CGRect shrinkRect = CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 290);
    [UIView animateWithDuration:0.5 animations:^{
        self.keyboardView.frame = shrinkRect;
    } completion:^(BOOL finished) {
        self.keyboardView.isShrink = true;
    }];
}

-(void)tapKeyboardHeaderView:(UITapGestureRecognizer *)recognizer {
    //如果获取到用户点击键盘上方（当键盘收缩的时候）就向上弹出
    if (self.keyboardView.isShrink) {
        [self expand];
    }
}


#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(80, 80);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
//        _collectionView.backgroundColor = [UIColor yellowColor];
        [_collectionView registerClass:[TimiItemCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    }
    return _collectionView;
}

- (KeyboardView *)keyboardView
{
    if (!_keyboardView)
    {
        _keyboardView = [[KeyboardView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-290, self.view.bounds.size.width, 290)];
        _keyboardView.backgroundColor = [UIColor clearColor];
        _keyboardView.isShrink = false;
        _keyboardView.delegate = self;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapKeyboardHeaderView:)];
        [_keyboardView addGestureRecognizer:tap];
    }
    return _keyboardView;
}

- (NSArray *)itemNameArr
{
    if (!_itemNameArr)
    {
        _itemNameArr = @[@"工资",@"日常",@"就餐",@"零食",@"充值",@"购物",@"娱乐",@"雪糕",@"生日",@"鞋帽",@"聚会",@"礼物",@"收入",@"工作",@"运动",@"普通"];
    }
    return _itemNameArr;
}

- (NSArray *)itemPicArr
{
    if (!_itemPicArr) {
        _itemPicArr = @[@"icon_salary.png",@"icon_daily.png",@"icon_dinner.png",@"icon_food.png",@"icon_phoneCharge.png",@"icon_shopping.png",@"icon_chess.png",@"icon_icecream.png",@"icon_birthday.png",@"icon_shoe.png",@"icon_party.png",@"icon_gift.png",@"icon_income.png",@"icon_work.png",@"icon_sport.png",@"icon_normal.png"];
    }
    return _itemPicArr;
}


- (UIImageView *)cellImageView
{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc] init];
    }
    return _cellImageView;
}

- (TimiItemCollectionViewCell *)selectedCell
{
    if (!_selectedCell) {
        _selectedCell = [[TimiItemCollectionViewCell alloc] init];
    }
    return _selectedCell;
}
@end
