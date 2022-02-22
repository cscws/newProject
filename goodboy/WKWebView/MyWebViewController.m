//
//  MyWebViewController.m
//  goodboy
//
//  Created by 闪闪的少女 on 2022/2/17.
//

#import "MyWebViewController.h"
#import <WebKit/WebKit.h>

@interface MyWebViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic, strong) WKWebView *wkView;
@end

@implementation MyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configWebView{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.minimumFontSize = 50;
    _wkView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    [self.view addSubview:_wkView];
    
    NSURL *url = [NSURL URLWithString:@"https://m.benlai.com/huanan/zt/1231cherry"];
    [_wkView loadRequest:[NSURLRequest requestWithURL:url]];
    
    WKUserContentController *userCC = config.userContentController;
    [userCC addScriptMessageHandler:self name:@"showMessage"];
    
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"data.txt" ofType:nil];
        NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [_wkView evaluateJavaScript:str completionHandler:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //这个是注入JS代码后的处理效果,尽管html已经有实现了,但是没用,还是执行JS中的实现
    if ([message.name isEqualToString:@"showMessage"]) {
        NSArray *array = message.body;
        NSLog(@"%@",array.firstObject);
        NSString *str = [NSString stringWithFormat:@"产品ID是: %@",array.firstObject];
        [self showMsg:str];
    }
}

#pragma mark - private
- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
