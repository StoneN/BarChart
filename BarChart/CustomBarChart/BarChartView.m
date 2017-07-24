//
//  BarChartView.m
//  BarChart
//
//  Created by StoneNan on 2017/7/24.
//  Copyright © 2017年 StoneNan. All rights reserved.
//

#define SCREEN_WIDTH    UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT   UIScreen.mainScreen.bounds.size.height
#define DefaultLineColor [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0]

#import "BarChartView.h"

static const CGFloat barChartTopSpacing = 40;
static const CGFloat barChartBottomSpacing = 40;
static const CGFloat barChartLeftSpacing = 50;
static const CGFloat barChartRightSpacing = 25;


static const int tagOffsetOfColumnValueLable = 1;
static const int tagOffsetOfColumnView = 100;
static const int tagOffsetOfShadowButton = 200;


struct Extremum
{
    CGFloat max;
    CGFloat min;
};


@interface BarChartView ()

@property(nonatomic,assign)BOOL isFirst;


@property(nonatomic,assign)CGFloat lineHeight;//行高
@property(nonatomic,assign)CGFloat columnWidth;//列宽

@property(nonatomic,strong)NSMutableArray *data;
@property(nonatomic,assign)BOOL isDataEmpty;//当前有效数据个数

@property(nonatomic,assign)NSInteger zeroLineIndex;//x轴位置
@property(nonatomic,assign)NSInteger plusLineNumber;
@property(nonatomic,assign)NSInteger average;//平均值
@property(nonatomic,strong)NSMutableArray *yCoordinate;//y轴刻度
@property(nonatomic,assign,readwrite)NSInteger selectedColumnIndex;

-(void)configureColumnElement;
-(void)reconfigureData;
-(void)reconfigureYCoordinate;
-(void)reconfigureColumnElement;

-(void)drawLinesAndYCoordinateWithContextRef:(CGContextRef)ctr andAttribute:(NSDictionary *)attribute;
-(void)drawColumns;
-(void)configureYCoordinateByData;

-(struct Extremum)getExtremumFromData;
-(void)updateColumns;
-(void)removeOldColumnElement;
-(BOOL)isTheDataEmpty;

-(void)sendDataValue:(CGFloat)dataValue atIndex:(NSInteger)index;

@end












@implementation BarChartView

// MARK: Init Funcs:
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        self.userInteractionEnabled = YES;

        self.data = [[NSMutableArray alloc]init];
        self.yCoordinate = [[NSMutableArray alloc]init];

        self.yUnit = @"单位";
        self.accuracy = 1;

        self.columnWidthScale = 0.6;

        self.isFirst = true;
        self.columnNumber = 3;
        self.lineNumber = 7;

        self.animateDuration = 0.7;

        self.backgroundColor = UIColor.yellowColor;
        self.columnColor = UIColor.grayColor;
        self.columnValueColor = UIColor.blackColor;
        self.columnSelectedColor = UIColor.greenColor;
        self.lineColor = DefaultLineColor;
        self.xLineColor = UIColor.blackColor;
        self.yUnitColor = UIColor.grayColor;
        self.yCoordinateColor = UIColor.grayColor;
        self.shadowButtonColor = UIColor.grayColor;
    }
    return self;
}





// MARK: Configure Funcs:
-(void)configureColumnElement
{
    for (NSInteger i = 0; i < _columnNumber; ++i) {
        CGRect columnRect;
        columnRect.origin.x = barChartLeftSpacing + (i + (1 - _columnWidthScale) / 2) * _columnWidth;
        columnRect.origin.y = barChartTopSpacing + _plusLineNumber * _lineHeight;
        columnRect.size.width = _columnWidth * _columnWidthScale;
        columnRect.size.height = 0;

        UILabel *columnValueLable = [[UILabel alloc]init];
        columnValueLable.frame = columnRect;
        columnValueLable.alpha = 0.0;
        columnValueLable.textColor = _columnValueColor;
        columnValueLable.tag = i + tagOffsetOfColumnValueLable;
        columnValueLable.adjustsFontSizeToFitWidth = true;
        columnValueLable.textAlignment = NSTextAlignmentCenter;

        UIView *columnView = [[UIView alloc]initWithFrame:columnRect];
        columnView.backgroundColor = _columnColor;
        columnView.tag = i + tagOffsetOfColumnView;

        CGRect shadowRect;
        shadowRect.origin.x = barChartLeftSpacing + i * _columnWidth;
        shadowRect.origin.y = 0;
        shadowRect.size.width = _columnWidth;
        shadowRect.size.height = self.frame.size.height;

        UIButton *shadowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shadowButton.frame = shadowRect;
        shadowButton.alpha = 0.2;
        shadowButton.backgroundColor = UIColor.clearColor;
        shadowButton.tag = i + tagOffsetOfShadowButton;

        [shadowButton addTarget:self action:@selector(clickColumn:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:columnView];
        [self addSubview:columnValueLable];
        [self addSubview:shadowButton];
    }
}



// MARK: Setter:
-(void)setColumnNumber:(NSInteger)columnNumber
{
    if (_isFirst) {
        self.isFirst = false;
    } else {
        [self removeOldColumnElement];
    }
    _columnNumber = columnNumber;
    [self reconfigureData];
    CGFloat barChartWidth = self.frame.size.width - barChartLeftSpacing - barChartRightSpacing;
    self.columnWidth = barChartWidth / _columnNumber;

    [self configureColumnElement];
}

-(void)setLineNumber:(NSInteger)lineNumber
{
    [self removeOldColumnElement];

    _lineNumber = lineNumber;
    self.zeroLineIndex = (_lineNumber - 1) / 2;
    self.plusLineNumber = _lineNumber - 1 - _zeroLineIndex;
    [self reconfigureYCoordinate];
    CGFloat barChartHeight = self.frame.size.height - barChartTopSpacing - barChartBottomSpacing;
    self.lineHeight = barChartHeight / (_lineNumber - 1);

    [self configureColumnElement];
}










// MARK: Draw Funcs:
-(void)drawRect:(CGRect)rect {

    CGContextRef ctr = UIGraphicsGetCurrentContext();
    NSDictionary *attribute;

    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentRight;
    attribute = @{
                  NSFontAttributeName:[UIFont systemFontOfSize:12],
                  NSParagraphStyleAttributeName:paragraph,
                  NSForegroundColorAttributeName:_yUnitColor
                  };
    [_yUnit drawInRect:CGRectMake(0, 16, 40, 22) withAttributes:attribute];

    attribute = @{
                  NSFontAttributeName:[UIFont systemFontOfSize:12],
                  NSParagraphStyleAttributeName:paragraph,
                  NSForegroundColorAttributeName:_yCoordinateColor
                  };
    [self drawLinesAndYCoordinateWithContextRef:ctr andAttribute:attribute];
    [self drawColumns];
}

-(void)drawLinesAndYCoordinateWithContextRef:(CGContextRef)ctr andAttribute:(NSDictionary *)attribute
{
    for (NSInteger i = _lineNumber - 1, j = 0; i >= 0; --i, ++j) {
        CGPoint start = CGPointMake(barChartLeftSpacing, barChartTopSpacing + j * _lineHeight);
        CGPoint end = CGPointMake(self.frame.size.width - barChartRightSpacing, start.y);

        [_lineColor set];
        CGContextSetLineWidth(ctr, 0.4);
        CGContextMoveToPoint(ctr, start.x, start.y);
        CGContextAddLineToPoint(ctr, end.x, end.y);
        CGContextStrokePath(ctr);

        if (![_yCoordinate[i] isEqualToString:@""]) {
            [_yCoordinate[i] drawInRect:CGRectMake(start.x - 35, start.y - 6, 30, 22) withAttributes:attribute];
        }
    }

    //[self drawToBoldXLineWithContextRef:ctr];
    CGPoint start = CGPointMake(barChartLeftSpacing, barChartTopSpacing + (_lineNumber - _zeroLineIndex - 1) * _lineHeight);
    CGPoint end = CGPointMake(start.x + self.frame.size.width - barChartLeftSpacing - barChartRightSpacing, start.y);

    [_xLineColor set];
    CGContextSetLineWidth(ctr, 0.6);
    CGContextMoveToPoint(ctr, start.x, start.y);
    CGContextAddLineToPoint(ctr, end.x, end.y);
    CGContextStrokePath(ctr);

}





-(void)drawColumns
{
    NSDictionary *attribute;

    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.alignment = NSTextAlignmentCenter;
    attribute = @{
                  NSFontAttributeName:[UIFont systemFontOfSize:12],
                  NSParagraphStyleAttributeName:paragraph,
                  NSForegroundColorAttributeName:_columnValueColor
                  };

    for (NSInteger i = 0; i < _data.count; ++i) {
        UIView *columnView = (UIView *)[self viewWithTag:i + tagOffsetOfColumnView];
        UILabel *columnValueLable = (UILabel *)[self viewWithTag:i + tagOffsetOfColumnValueLable];

        CGRect columnViewRect = columnView.frame;
        CGRect labelRect = columnViewRect;

        if (![_data[i] isEqualToString:@""]) {
            CGFloat newValue = [_data[i] floatValue];
            CGFloat oldValue = [columnValueLable.text floatValue];

            columnValueLable.text = _data[i];

            if (newValue > 0) {
                CGFloat scale = newValue / [_yCoordinate.lastObject floatValue];
                columnViewRect.origin.y = barChartTopSpacing + (1 - scale) * _plusLineNumber * _lineHeight;
                columnViewRect.size.height = scale * _plusLineNumber * _lineHeight;
                labelRect.origin.y = columnViewRect.origin.y - 22;
                labelRect.size.height = 22;
            }
            if (newValue < 0) {
                CGFloat scale = newValue / [_yCoordinate.firstObject floatValue];
                columnViewRect.origin.y = barChartTopSpacing + _plusLineNumber * _lineHeight;
                columnViewRect.size.height = scale * _plusLineNumber * _lineHeight;
                labelRect.origin.y = barChartTopSpacing + _plusLineNumber * _lineHeight + columnViewRect.size.height;
                labelRect.size.height = 22;
            }
            if ((oldValue > 0 && newValue < 0) || (oldValue < 0 && newValue > 0)) {
                CGRect temp = CGRectMake(columnViewRect.origin.x, barChartTopSpacing + _plusLineNumber * _lineHeight, columnViewRect.size.width, 0);

                [UIView animateWithDuration:_animateDuration / 2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    columnView.frame = temp;
                    columnValueLable.frame = temp;
                    columnValueLable.alpha = 0.0;
                }  completion:^(BOOL finished) {
                    [UIView animateWithDuration:_animateDuration / 2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        columnView.frame = columnViewRect;
                        columnValueLable.frame = labelRect;
                        columnValueLable.alpha = 1.0;
                    } completion:nil];
                }];
            }
            else {
                [UIView animateWithDuration:_animateDuration animations:^{
                    columnView.frame = columnViewRect;
                    columnValueLable.frame = labelRect;
                    columnValueLable.alpha = 1.0;
                }];
            }
        } else {
            columnValueLable.text = @"";

            columnViewRect.origin.y = barChartTopSpacing + _plusLineNumber * _lineHeight;
            columnViewRect.size.height = 0;

            [UIView animateWithDuration:_animateDuration animations:^{
                columnView.frame = columnViewRect;
                columnValueLable.frame = columnViewRect;
                columnValueLable.alpha = 0.0;
            }];
        }
    }
}










// MARK: Set Funcs:


-(void)configureYCoordinateByData
{
    struct Extremum extremumValue = [self getExtremumFromData];

    CGFloat maxValue = extremumValue.max;
    CGFloat minValue = extremumValue.min;

    if (maxValue == 0 && minValue == 0) {
        [self reconfigureYCoordinate];
    } else {
        CGFloat max;
        if (fabs(maxValue) > fabs(minValue)) {
            max = fabs(maxValue);
        } else {
            max = fabs(minValue);
        }
        CGFloat averageValue;
        NSInteger lines = (_lineNumber - 1) / 2;
        averageValue = max / lines;
        self.average = (NSInteger)ceilf(averageValue);

        for (NSInteger i = 0; i < _lineNumber; ++i) {
            [_yCoordinate setObject:[NSString stringWithFormat:@"%ld", _average * (0 - lines + i)] atIndexedSubscript:i];
        }
    }
}






// MARK: Actions:
-(void)clickColumn:(UIButton *)button
{
    NSLog(@"click at: %li", button.tag - tagOffsetOfShadowButton);
    self.selectedColumnIndex = button.tag - tagOffsetOfShadowButton;
    
    if (_delegate && [_delegate respondsToSelector: @selector(clickedColumn)]) {
        [_delegate clickedColumn];
    }
    [self updateColumns];
}






// MARK: API Funcs:
-(void)sendDataValue:(CGFloat)dataValue atIndex:(NSInteger)index
{
    if (_isDataEmpty == true) {
        self.isDataEmpty = false;
    }
    if (dataValue == 0) {
        [_data setObject:@"" atIndexedSubscript:index];
        self.selectedColumnIndex = -1;
        _isDataEmpty = [self isTheDataEmpty];
    }
    else {
        NSString *dateValueStr;
        switch (_accuracy) {
            case 0:
                dateValueStr = [NSString stringWithFormat:@"%.0f", dataValue];
                break;
            case 1:
                dateValueStr = [NSString stringWithFormat:@"%.1f", dataValue];
                break;
            case 2:
                dateValueStr = [NSString stringWithFormat:@"%.2f", dataValue];
                break;
            case 3:
                dateValueStr = [NSString stringWithFormat:@"%.3f", dataValue];
                break;
            case 4:
                dateValueStr = [NSString stringWithFormat:@"%.4f", dataValue];
                break;
            default:
                dateValueStr = [NSString stringWithFormat:@"%.f", dataValue];
                break;
        }

        if (index < 0 || index >= _columnNumber) {
            NSInteger i;
            for (i = 0; i < _data.count; ++i) {
                if ([_data[i] isEqualToString:@""]) {
                    [_data setObject:dateValueStr atIndexedSubscript:i];
                    self.selectedColumnIndex = i;
                    break;
                }
            }
            if (i == _data.count) {
                [_data setObject:dateValueStr atIndexedSubscript:i - 1];
                self.selectedColumnIndex = i - 1;
            }
        } else {
            [_data setObject:dateValueStr atIndexedSubscript:index];
            self.selectedColumnIndex = index;
        }
    }
    [self configureYCoordinateByData];
    [self updateColumns];
    [self setNeedsDisplay];
}










// MARK: Help Funcs:
-(struct Extremum)getExtremumFromData
{
    CGFloat maxValue = 0;
    CGFloat minValue = 0;
    for (NSInteger i = 0 ; i < _data.count ; ++i) {
        if ([_data[i] isEqualToString:@""]) {
            continue;
        }
        NSString *temp = _data[i];
        CGFloat tempValue = [temp floatValue];

        if (tempValue > maxValue) {
            maxValue = tempValue;
        }
        if (tempValue < minValue) {
            minValue = tempValue;
        }
    }
    struct Extremum extremumValue;
    extremumValue.max = maxValue;
    extremumValue.min = minValue;

    return extremumValue;
}

-(void)updateColumns
{
    [self reconfigureColumnElement];

    UIButton *selectedShadowButton = (UIButton *)[self viewWithTag:_selectedColumnIndex + tagOffsetOfShadowButton];
    selectedShadowButton.backgroundColor = _shadowButtonColor;

    UIView *selectedColumnView = (UIView *)[self viewWithTag:_selectedColumnIndex + tagOffsetOfColumnView];
    selectedColumnView.backgroundColor = _columnSelectedColor;
}

-(void)reconfigureColumnElement
{
    UIButton *shadowButton;
    UIView *columnView;
    for (NSInteger i = 0; i < _columnNumber; ++i) {
        shadowButton = (UIButton *)[self viewWithTag:i + tagOffsetOfShadowButton];
        shadowButton.backgroundColor = UIColor.clearColor;

        columnView = (UIView *)[self viewWithTag:i + tagOffsetOfColumnView];
        columnView.backgroundColor = _columnColor;
    }
}

-(void)reconfigureData
{
    [_data removeAllObjects];
    for (NSInteger i = 0; i < _columnNumber; ++i) {
        [_data addObject:@""];
    }
    self.isDataEmpty = true;
    self.selectedColumnIndex = -1;
}

-(void)reconfigureYCoordinate
{
    [_yCoordinate removeAllObjects];
    for (NSInteger i = 0; i < _lineNumber; ++i) {
        if (i == _zeroLineIndex) {
            [_yCoordinate addObject:@"0"];
        } else {
            [_yCoordinate addObject:@""];
        }
    }
}

-(void)removeOldColumnElement
{
    for (NSInteger i = 0; i < _columnNumber; ++i) {
        UIButton *oldButton = (UIButton *)[self viewWithTag:i + tagOffsetOfShadowButton];
        UILabel *oldLable = (UILabel *)[self viewWithTag:i + tagOffsetOfColumnValueLable];
        UIView *oldView = (UIView *)[self viewWithTag:i + tagOffsetOfColumnView];
        [oldButton removeFromSuperview];
        [oldLable removeFromSuperview];
        [oldView removeFromSuperview];
    }
}

-(BOOL)isTheDataEmpty
{
    for (NSInteger i = 0; i < _data.count; ++i) {
        if ([_data[i] isEqualToString:@""]) {
            continue;
        }
        return false;
    }
    return true;
}







@end

