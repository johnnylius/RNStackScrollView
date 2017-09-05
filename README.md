# RNStackScrollView

可将ScrollView、WebView、TableView等组合成一体，实现无缝流畅滚动。该组件自动监听内容尺寸变化，实现自动布局，对使用者完全透明。适用场景，如，今日头条、天天快报、今日十大热点等新闻客户端详情页，新闻头部为UIView，新闻内容为UIWebView，评论部分为UITable。
### 显示样式
<img src="scroll.gif" width=375>

### 使用代码
``` objectivec
NSArray *viewArray = @[self.headerView, self.webView, self.tableView];
self.scrollView = [[RNStackScrollView alloc] initWithViewArray:viewArray];
self.scrollView.frame = self.view.bounds;
[self.view addSubview:self.scrollView];
```
