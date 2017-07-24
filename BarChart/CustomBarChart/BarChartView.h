//
//  BarChartView.h
//  BarChart
//
//  Created by StoneNan on 2017/7/24.
//  Copyright © 2017年 StoneNan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BarChartViewDelegate <NSObject>

-(void)clickedColumn;//处理按钮点击事件

@end


@interface BarChartView : UIView

@property(nonatomic,strong)UIColor *columnColor;    //柱子颜色（默认：yellow）
@property(nonatomic,strong)UIColor *columnValueColor;   //柱子上/下的数值颜色（默认：black）
@property(nonatomic,strong)UIColor *columnSelectedColor;    //柱子在被选中状态的颜色（默认：green）
@property(nonatomic,strong)UIColor *shadowButtonColor;  //柱子被选中时阴影的颜色（默认：gray）
@property(nonatomic,strong)UIColor *lineColor;  //y刻度线的颜色（默认：gray）
@property(nonatomic,strong)UIColor *xLineColor; //x轴的颜色（默认：black）
@property(nonatomic,strong)UIColor *yUnitColor; //单位Label的颜色（默认：gray）
@property(nonatomic,strong)UIColor *yCoordinateColor;   //y刻度值的颜色（默认：gray）

@property(nonatomic,strong)NSString *yUnit; //单位（默认：@“单位”）

@property(nonatomic,assign)NSInteger lineNumber; //y刻度线的数量,请设置为>=3的奇数以保证x轴在中间（默认：7）
@property(nonatomic,assign)NSInteger columnNumber;  //柱子数量（默认：3）
@property(nonatomic,assign)NSInteger accuracy;//数据精度，小数点后几位（默认：1，表示1位小数）

@property(nonatomic,assign)CGFloat animateDuration; //数据改变时柱子的动画时间（默认：0.7）
@property(nonatomic,assign)CGFloat columnWidthScale;    //柱子相对宽度比，0～1（默认：0.6）

@property(nonatomic,assign,readonly)NSInteger selectedColumnIndex;   //当前被选中柱子的下标

@property(nonatomic, weak)id<BarChartViewDelegate> delegate;


-(void)sendDataValue:(CGFloat)dataValue atIndex:(NSInteger)index;

@end
