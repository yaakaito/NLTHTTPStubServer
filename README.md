# NLTHTTPStubServer
NLTHTTPStubServer is mocking server.
launch simple HTTPServer on testcodes.

# Usage 
How to install

# Feature

on GHUnit and ASIHTTPRequest
 
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
 
    GHAssertEquals(200, [request responseStatusCode], @"status code");
    GHAssertEqualStrings(@"Hello World", [request responseString], @"response");
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
    
    GHAssertEquals(200, [request responseStatusCode], @"status code");
    
    NSError *error=nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];   
    GHAssertEqualStrings(@"ok", [json objectForKey:@"status"], @"status!=ok");

}
```
