# NLTHTTPStubServer
* localhostにサーバーを立ててくれます
* レスポンスをコードで書いて登録します
* localhostへアクセスします
* レスポンスが帰ってきます
* apachecとか使ってやったりするアレです
## Feature
exsample on GHUnit

```objective-c
- (void)setUpClass {
    [NLTHTTPStubServer globalSettings].port = 12345;
    
    server = [[NLTHTTPStubServer stubServer] retain];
    [server startServer];
}

- (void)tearDownClass {

    [server stopServer];
    [server release];
}

- (void)setUp {
    [server clear];
}

- (void)tearDown {
    if(![server isStubEmpty]) {
        GHFail(@"stubs not empty");
    }
}

- (void)testText {
    
    NSData *helloWorld = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    [server addStubResponse:[NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                           statusCode:200
                                                                 data:helloWorld]];
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];

    
    GHAssertEquals(200, [request responseStatusCode], @"ステータスコードが違う");
    GHAssertEqualStrings(@"Hello World", [request responseString], @"レスポンス内容が違う");
}


- (void)testJSON {
    NSData *jsonData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [server addStubResponse:[NLTHTTPStubResponse stubResponseWithPath:@"/index"
                                                           statusCode:200
                                                                 data:jsonData]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEquals(200, [request responseStatusCode], @"ステータスコードが違う");
    
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];   
    GHTestLog(@"%@", json.description);
    GHAssertEqualStrings(@"ok", [json objectForKey:@"status"], @"status=okじゃない");

}
```
