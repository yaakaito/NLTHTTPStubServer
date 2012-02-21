# NLTHTTPStubServer
* なんとか既存のコードでHTTPリクエスト投げてパースして〜系のテストを少しの変更でできるようにしたい
## Feature
exsample on GHUnit

```objective-c
- (void)setUpClass {
    [NLTHTTPStubServer globalSettings].port = 12345;
    [NLTHTTPStubServer globalSettings].shouldAutoStart = YES;
    server =  [NLTHTTPStubServer stubServer];
}

- (void)setUp {
    [server clear];
}

- (void)tearDown {
    if(![server isEmpty]){
        GHFail(@"dont call %f stubs", [server.stubs count]);
    }
}

- (void)testHttpRequest {
    [[[server next] andStatusCode:200] andResponse:[NLTResponse jsonResponseWithData:[NSData data]]];
    [[[server next] andStatusCode:200] andResponse:[NLTResponse jsonResponseWithData:[NSData data]]];
    [self prepare];
    // throw 2 httprequests and parsers
    NLFooClient *client = [NLFooClient client];
    client.firstRequest.url = [NSURL URLWithString:@"http://localhost:12345/first?k=v"];
    client.secondRequest.url = [NSURL URLWithString:@"http://localhost:12345/second?k=v"];
    [client startRequestWithComplete:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [self waitForTimeout:kGHUnitWaitStatusSuccess];
}
```
