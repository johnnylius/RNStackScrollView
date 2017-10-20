//
//  ViewController.m
//  RNDetailViewDemo
//
//  Created by Sogou on 16/7/20.
//  Copyright © 2016年 Sogou. All rights reserved.
//

#define viewSize self.view.frame.size
#define viewWidth viewSize.width
#define viewHeight viewSize.height

#import "ViewController.h"
#import "RNStackScrollView.h"

@interface ViewController () <UIScrollViewDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RNStackScrollView *scrollView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *viewArray = @[self.headerView, self.webView, self.tableView];
    self.scrollView = [[RNStackScrollView alloc] initWithViewArray:viewArray];
    self.scrollView.frame = self.view.bounds;
    [self.view addSubview:self.scrollView];
    [self loadHtml];
}

#pragma mark - Getter and Setter
- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] init];
        _headerView.frame = CGRectMake(0, 0, 0, 60);
        _headerView.backgroundColor = [UIColor redColor];
    }
    return _headerView;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor redColor];
    }
    return _webView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor redColor];
        self.count = 100;
    }
    return _tableView;
}

#pragma mark - Private Method
- (void)loadHtml {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_webView loadHTMLString:htmlString baseURL:baseURL];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blueColor];
        cell.backgroundView = view;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        if (scrollView.contentOffset.y > 3000) {
            if (self.count != 300) {
                self.count = 300;
                [self.tableView reloadData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
