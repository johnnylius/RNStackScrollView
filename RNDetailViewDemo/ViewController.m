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

@interface ViewController () <UIScrollViewDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGRect tableViewFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = self.view.bounds;
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.scrollEnabled = NO;
    [self.scrollView addSubview:self.webView];
    [self loadHtml];
    self.webView.backgroundColor = [UIColor redColor];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.frame = CGRectMake(0, viewHeight, viewWidth, viewHeight);
    [self.scrollView addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor blueColor];
    
    self.scrollView.contentSize = CGSizeMake(viewWidth, viewHeight * 6);
}

#pragma mark - Private Method
- (void)loadHtml {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [_webView loadHTMLString:htmlString baseURL:baseURL];
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webView: contentSizeHeight = %f", webView.scrollView.contentSize.height);
    
    self.scrollView.contentSize = CGSizeMake(viewWidth, webView.scrollView.contentSize.height + 44 * 200);
    self.tableViewFrame = CGRectMake(0, webView.scrollView.contentSize.height, viewWidth, viewHeight);
    self.tableView.frame = self.tableViewFrame;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor greenColor];
        cell.backgroundView = view;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", indexPath.row];
    NSLog(@"row = %zd", indexPath.row);
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:NSClassFromString(@"_UIWebViewScrollView")] ||
        [scrollView isKindOfClass:[UITableView class]]) {
        return;
    }

    NSLog(@"scrollView: x = %f, y = %f", scrollView.contentOffset.x, scrollView.contentOffset.y);
    
    
    //
    CGFloat webViewMaxContentOffsetY = self.webView.scrollView.contentSize.height - self.webView.frame.size.height;
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < 0) {
        offset.y = 0;
    }
    
    CGPoint webViewOffset = offset;
    CGRect webViewFrame = self.webView.frame;
    webViewFrame.origin = offset;
    if (webViewOffset.y > webViewMaxContentOffsetY) {
        webViewOffset.y = webViewMaxContentOffsetY;
        webViewFrame.origin = webViewOffset;
    }
    
    self.webView.scrollView.contentOffset = webViewOffset;
    self.webView.frame = webViewFrame;
    NSLog(@"webView: x = %f, y = %f", self.webView.frame.origin.x, self.webView.frame.origin.y);
    
    
    //
    CGFloat tableViewMaxContentOffsetY = self.tableView.contentSize.height - self.tableView.frame.size.height;
    
    if (offset.y < webViewMaxContentOffsetY + self.tableView.frame.size.height) {
        offset.y = webViewMaxContentOffsetY + self.tableView.frame.size.height;
    }

    offset.y = offset.y - (webViewMaxContentOffsetY + self.tableView.frame.size.height);
    CGPoint tableViewOffset = offset;
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y = self.tableViewFrame.origin.y + offset.y;
    if (tableViewOffset.y > tableViewMaxContentOffsetY) {
        tableViewOffset.y = tableViewMaxContentOffsetY;
        tableViewFrame.origin.y = self.tableViewFrame.origin.y + tableViewOffset.y;
    }
    
    
    self.tableView.frame = tableViewFrame;
    self.tableView.contentOffset = tableViewOffset;
    NSLog(@"tableView: x = %f, y = %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
