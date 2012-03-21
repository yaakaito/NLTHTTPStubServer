# NLTHTTPStubServer
NLTHTTPStubServer is mocking server.
launch simple HTTPServer on testcodes.

# Usage 
How to install

# Feature

on GHUnit and ASIHTTPRequest

## setup
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
```
## e.g.
### NSData
```objective-c
- (void)testNSData {
    NSData *helloWorld = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = helloWorld;
    [server addStubResponse:stub];
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
 
    GHAssertEquals(200, [request responseStatusCode], @"status code");
    GHAssertEqualStrings(@"Hello World", [request responseString], @"response");
}
```

### JSON(NSData)
```objective-c
- (void)testJSON {
    NSData *jsonData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = jsonData;
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEquals(200, [request responseStatusCode], @"status code");
    
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];   
    GHAssertEqualStrings(@"ok", [json objectForKey:@"status"], @"status!=ok");

}
```

### File
```objective-c
- (void)testFile {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}
```

### checking URI
```objective-c
- (void)testCheckQuery {
    NLTHTTPStubResponse *stub = [NLTStubResponse httpFileResponse];
    stub.path = @"/index";
    stub.filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test"
                                                                     ofType:@"txt"];
    [stub URICheckWithBlock:^BOOL(NSURL *URI) {
        // check relative URL
        return YES;
    }];
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index?key=value"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
}
```

### status code 
```objective-c
- (void)testNotFound {
    NSData *notFound = [@"404 Not Found" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.statusCode = 404;
    stub.data = notFound;
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    [self prepare];
    [request setCompletionBlock:^{
        [self notify:kGHUnitWaitStatusSuccess];
    }];
    [request startAsynchronous];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
    
    GHAssertEquals(404, [request responseStatusCode], @": (");
}
```

### timeout
```objective-c
- (void)testTimeout {
    NSData *response = [@"hoge" dataUsingEncoding:NSUTF8StringEncoding];
    NLTHTTPStubResponse *stub = [NLTStubResponse httpDataResponse];
    stub.path = @"/index";
    stub.data = response;
    stub.shouldTimeout = YES;
    [server addStubResponse:stub];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/index"]];
    request.timeOutSeconds = 2.0f;
    [request startSynchronous];
    GHAssertEquals(request.error.code, ASIRequestTimedOutErrorType, @"oops...");
}
```
