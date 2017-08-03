 //
//  ViewController.m
//  BarChart
//
//  Created by StoneNan on 2017/7/24.
//  Copyright © 2017年 StoneNan. All rights reserved.
//

#define SCREEN_WIDTH    UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT   UIScreen.mainScreen.bounds.size.height

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate,BarChartViewDelegate>

@property(strong,nonatomic)IBOutlet UISegmentedControl *segment;
@property(strong,nonatomic)IBOutlet UIButton *randValue;
@property(strong,nonatomic)IBOutlet UIButton *delete;
@property(strong,nonatomic)IBOutlet UITextField *changeDataTextField;
@property(strong,nonatomic)IBOutlet UIStepper *ColumnStepper;
@property(strong,nonatomic)IBOutlet UIStepper *LineStepper;

@property(strong,nonatomic)BarChartView *barChartView;

@end






@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
   
    _barChartView = [[BarChartView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_WIDTH)];
    _barChartView.shadowButtonColor = UIColor.redColor;
    
//    _barChartView.chartType = ChartTypeOnlyPlus;
//    _barChartView.chartType = ChartTypeOnlyMinus;
    
    
    [self.view addSubview:_barChartView];
    
    _barChartView.delegate = self;
    
    _changeDataTextField.delegate = self;
    _ColumnStepper.value = _barChartView.columnNumber;
    _LineStepper.value = _barChartView.lineNumber;
    [_segment setHidden:true];
}

-(void)clickedColumn
{
    NSLog(@"clickedColumnIndex:%li",_barChartView.selectedColumnIndex);
}


-(void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}

// MARK: delegate:
-(void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardHeight = keyboardRect.size.height;
    NSLog(@"keyboardWillShow");
    CGFloat oldY = self.view.frame.origin.y;
    CGFloat spacing = SCREEN_HEIGHT - _changeDataTextField.frame.origin.y - _changeDataTextField.frame.size.height - 10 - keyboardHeight;
    if (spacing < 0) {
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = oldY + spacing;
        NSLog(@"%f",newFrame.origin.y);
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = newFrame;
        }];
    }
}
-(void)keyboardWillHide:(NSNotification *)aNotification
{
    NSLog(@"keyboardWillHide");
}


// MARK: Action:

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
    self.barChartView.chartType = sender.selectedSegmentIndex;
    _barChartView.columnNumber = _barChartView.columnNumber;
}

- (IBAction)clickRandValue:(UIButton *)sender {
    
    NSInteger columnIndex = arc4random() % _barChartView.columnNumber;
    NSInteger value = arc4random() % 100;
    NSLog(@"click rand value: value:%ld, at:%li",(long)value,(long)columnIndex);
    if (value % 2 == 0) {
        value = 0 - value;
    }
    [_barChartView sendDataValue:value atIndex:columnIndex];
}
- (IBAction)delete:(UIButton *)sender {
    NSLog(@"click delete!");
    [_barChartView sendDataValue:0 atIndex:_barChartView.selectedColumnIndex];
}



- (IBAction)begin:(UITextField *)sender {
    NSLog(@"begin setting!");
    
}

- (IBAction)finish:(UITextField *)sender {
    NSLog(@"finish setting!");
    CGFloat value = [sender.text floatValue];
    [_barChartView sendDataValue:value atIndex:_barChartView.selectedColumnIndex];
    CGRect newFrame = self.view.frame;
    newFrame.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = newFrame;
    }];
}






- (IBAction)changeColumnNumber:(UIStepper *)sender {
    NSLog(@"change Column Number!");
    _barChartView.columnNumber = sender.value;
}
- (IBAction)changeLineNumber:(UIStepper *)sender {
    NSLog(@"change Line Number! :%f", sender.value);
    _barChartView.lineNumber = sender.value;
}
- (IBAction)changeLableSwitch:(UISwitch *)sender {
    NSLog(@"%i", sender.isOn);
}



@end
