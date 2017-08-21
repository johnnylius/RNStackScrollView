//
//  ViewController.m
//  RNDetailViewDemo
//
//  Created by ryan on 16/7/20.
//  Copyright © 2016年 ryan. All rights reserved.
//

#define viewSize self.view.frame.size
#define viewWidth viewSize.width
#define viewHeight viewSize.height

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>


@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UITableView *tableView;



@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = self.view.bounds;
    webView.delegate = self;
    webView.scrollView.delegate = self;
    webView.scrollView.bounces = NO;
    webView.backgroundColor = [UIColor redColor];
    self.webView = webView;
    [self loadHtml];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = webView;
    tableView.bounces = NO;
    tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
}

#pragma mark 记载html
- (void)loadHtml{
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_webView loadHTMLString:htmlString baseURL:baseURL];
    
}

#pragma mark tableView 行高
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",arc4random() % 100];
    
    return cell;
    
}

#pragma mark scrollview delegate (计算contentOffset的值，根据上下距离来决定bounces)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat top = scrollView.contentOffset.y;
    
    NSLog(@"top = %f,height = %f",top,_tableView.contentSize.height - viewHeight - 100);
    
    if ([scrollView isKindOfClass:[UITableView class]]) {
        if (top > (_tableView.contentSize.height - viewHeight - 100)) {
            _tableView.bounces = YES;
        }else{
            _tableView.bounces = NO;
        }
    }else if(scrollView == _webView.scrollView){
        if (top > 30) {
            _tableView.bounces = NO;
        }else{
            _tableView.bounces = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
