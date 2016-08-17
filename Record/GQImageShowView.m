//
//  GQImageShowView.m
//  AMAP3DDemo
//
//  Created by Lidear on 15/11/27.
//  Copyright © 2015年 zhuang. All rights reserved.
//

#define img_max_count 3

#import "GQImageShowView.h"

@interface GQImageShowView ()

@property (nonatomic, strong) UIScrollView *backSV;
@property (nonatomic, strong) NSMutableArray *imageViewsArr;        //  图片按钮
@property (nonatomic, strong) NSMutableArray *imageViewsBtnArr;     //  删除按钮
//@property (nonatomic, assign) NSInteger imageNextX;
@property (nonatomic, strong) UIButton *addImageBtn;

@end

@implementation GQImageShowView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_backSV ) {
        [self createViews];
    }
}

- (void)createViews
{
    _showImgArr = [NSMutableArray array];
    _imageViewsArr = [NSMutableArray array];
    
    _backSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 8, self.frame.size.width, self.frame.size.height - 16)];
    [_backSV setShowsHorizontalScrollIndicator:NO];
    [_backSV setClipsToBounds:NO];
    [self addSubview:_backSV];
    
    if (_isNeedAddBtn) {
//        _addImageBtn = LDButton(0, 0, _backSV.viewHeight, _backSV.viewHeight);
        _addImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _backSV.frame.size.height, _backSV.frame.size.height)];
        [_addImageBtn setHidden:NO];
//        [_addImageBtn setBackgroundColor:LDRedColor];
        [_addImageBtn setBackgroundColor:[UIColor redColor]];
        [_addImageBtn setImage:[UIImage imageNamed:@"upload.png"] forState:UIControlStateNormal];
        [_addImageBtn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
        [_backSV addSubview:_addImageBtn];
        
    } else {
        [_addImageBtn setHidden:YES];
    }
}

- (void)addImages:(NSMutableArray *)images
{
    [self addImages:images isDeleting:NO];
}


- (void)addImages:(NSMutableArray *)images isDeleting:(BOOL)isDeleting
{
    if (!_backSV) {
        [self createViews];
    }
    
    //  添加新数据
    [_showImgArr addObjectsFromArray:images];
    
    if (_showImgArr.count >= img_max_count) {
        _isNeedAddBtn = NO;
        [_addImageBtn setHidden:YES];
    }
    
    if (isDeleting) {
        _isNeedAddBtn = YES;
        [_addImageBtn setHidden:NO];
        
        if (_showImgArr.count == 0) {
            CGRect frame = _addImageBtn.frame;
            frame.origin.x = 0;
            _addImageBtn.frame = frame;
//            [_addImageBtn setViewX:0];
        }
    }
    
    //  删除原有图片
    for (UIImageView *iv in _imageViewsArr) {
        [iv removeFromSuperview];
    }
    
    NSInteger imageNextX = 0;
    NSInteger index = 0;
    
    for (UIImage *img in _showImgArr) {
        CGFloat ivWidth = _backSV.frame.size.height / img.size.height * img.size.width;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(imageNextX, 0, _backSV.frame.size.height, _backSV.frame.size.height)];
        [iv setImage:img];
        [iv setUserInteractionEnabled:YES];
        [_backSV addSubview:iv];
        [_imageViewsArr addObject:iv];
        
        //  响应btn
        UIButton *btn = [[UIButton alloc] initWithFrame:iv.bounds];
        [btn addTarget:self action:@selector(clickImage) forControlEvents:UIControlEventTouchUpInside];
        [iv addSubview:btn];
        
        //  重置
        imageNextX += _backSV.frame.size.height + 8;
        [_backSV setContentSize:CGSizeMake(imageNextX, 0)];
        
        //  删除
        if (_isNeedDeleteBtn) {
//            UIButton *deleteBtn = [UIButton buttonWithFrame:CGRectMake(iv.frame.size.width - 40, 0, 40, 40) title:nil font:nil backColor:nil img:@"gq_img_delete_icon" corner:0 tag:index];
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(iv.frame.size.width - 40, 0, 40, 40)];
            [deleteBtn setImage:[UIImage imageNamed:@"gq_img_delete_icon"] forState:UIControlStateNormal];
            deleteBtn.tag = index;
            [deleteBtn addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
            [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(-30, 0, 0, -30)];
            [iv addSubview:deleteBtn];
        }
        
        //  添加
        if (_isNeedAddBtn) {
//            [_addImageBtn setViewX:imageNextX];
            CGRect frame = _addImageBtn.frame;
            frame.origin.x = imageNextX;
            _addImageBtn.frame = frame;
            [_backSV setContentSize:CGSizeMake(_addImageBtn.frame.origin.x + _addImageBtn.frame.size.width + 8, 0)];
        }
        
        index++;
    }
}

- (void)clickDeleteBtn:(UIButton *)btn
{
    [_showImgArr removeObjectAtIndex:btn.tag];
    [self addImages:nil isDeleting:YES];
}

- (void)clickAddBtn
{
    if (_blockClickAdd) {
        _blockClickAdd();
    }
}

- (void)clickImage
{
    if (_blockClickImage) {
        _blockClickImage();
    }
}

@end
