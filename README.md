# NLTHTTPStubServer

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
    [client startRequestWithComplete:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [self waitForTimeout:kGHUnitWaitStatusSuccess];
}
```
