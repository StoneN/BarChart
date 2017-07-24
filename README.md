# BarChartView

A simple Column Chart View which can display the real-time data and is also highly customized.

![barChartViewDemo](https://raw.githubusercontent.com/StoneN/BarChart/master/PicturesForREADME/barChartViewDemo.gif)



### 使用方法：

- 拷贝以下文件到你的项目中:

  > BarChartView.h
  >
  > BarChartView.m

- 导入头文件并使用 `initWithFrame:` 初始化 `view` ：

  ~~~objective-c
  #import "BarChartView.h"
  //......
  //......
  @property(strong,nonatomic)BarChartView *barChartView;
  //......
  //......
  _barChartView = [[BarChartView alloc]
                   initWithFrame:CGRectMake(x,y,width,height)];
  ~~~

- 通过 `点操作` 或 `设值方法` 来自定义 view 的一些属性，可定义的属性如下：

  ~~~objective-c
  @property(nonatomic,strong)UIColor *columnColor;    
  //柱子颜色（默认：yellow）

  @property(nonatomic,strong)UIColor *columnValueColor;   
  //柱子上/下的数值颜色（默认：black）

  @property(nonatomic,strong)UIColor *columnSelectedColor;    
  //柱子在被选中状态的颜色（默认：green）

  @property(nonatomic,strong)UIColor *shadowButtonColor;  
  //柱子被选中时阴影的颜色（默认：gray）

  @property(nonatomic,strong)UIColor *lineColor;  
  //y刻度线的颜色（默认：gray）

  @property(nonatomic,strong)UIColor *xLineColor; 
  //x轴的颜色（默认：black）

  @property(nonatomic,strong)UIColor *yUnitColor; 
  //单位Label的颜色（默认：gray）

  @property(nonatomic,strong)UIColor *yCoordinateColor;   
  //y刻度值的颜色（默认：gray）

  @property(nonatomic,strong)NSString *yUnit; 
  //单位（默认：@“单位”）

  @property(nonatomic,assign)NSInteger lineNumber; 
  //y刻度线的数量,请设置为>=3的奇数以保证x轴在中间（默认：7）

  @property(nonatomic,assign)NSInteger columnNumber;  
  //柱子数量（默认：3）

  @property(nonatomic,assign)NSInteger accuracy;
  //数据精度，小数点后几位（默认：1，表示1位小数）

  @property(nonatomic,assign)CGFloat animateDuration; 
  //数据改变时柱子的动画时间（默认：0.7）

  @property(nonatomic,assign)CGFloat columnWidthScale;    
  //柱子相对宽度比，0～1（默认：0.6）

  //#################################
  @property(nonatomic,assign,readonly)NSInteger selectedColumnIndex;   
  //当前被选中柱子的下标,为只读属性
  ~~~

- 可选择实现 `BarChartViewDelegate` :

  ~~~objective-c
  @protocol BarChartViewDelegate <NSObject>
  -(void)clickedColumn;//当用户点击某柱数据时，将回调该方法
  @end
  ~~~

- 调用方法将要展示的数据传给 `view` 进行显示

  ~~~objective-c
  -(void)sendDataValue:(CGFloat)dataValue atIndex:(NSInteger)index;
  //index表示柱子下标，自左向右依次为：0，1，2...
  //要清楚某列数据，只需调用：sendDataValue:0 atIndex:index；
  ~~~

  ​

### 说明：

由于实习公司的项目需要用到一个简单的条形图View，仅实现 实时更新显示固定数据，并能够讲用户选中的对象传给后台的简单功能，而网上的相关框架功能都太复杂。

为避免牛刀杀鸡，我自己写了这么个View。。。这也是我学OC以来所写的“处女View”，写的很烂，功能也极其有限，还请见谅。。。

##### 目前功能内的缺陷：

> 无法动态更改 柱子数量 和 y刻度线数量，只能于定义之初进行设置，之后你可能会更改完善。

