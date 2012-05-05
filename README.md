# NLTHTTPStubServer
NLTHTTPStubServer is mocking server.
launch simple HTTPServer on testcodes.

# How to install 
[CocoaPods](https://github.com/CocoaPods/)

# Usage

GHUnit and AFNetworking example

```objective-c
@implementation NLTHTTPStubServerWithAFNetwrokingTest

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

- (void)testJSONResponse {
    
    [[[server stub] forPath:@"/index.json"] andJSONResponseResource:@"test" ofType:@"json"]; // create stub response
    
    [self prepare];
    NSURL *url = [NSURL URLWithString:@"http://localhost:12345/index.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        GHAssertEqualStrings(@"ok", [JSON objectForKey:@"status"], @"status = ok");
        GHAssertEqualStrings(@"json", [JSON objectForKey:@"format"], @"format = json");
        [self notify:kGHUnitWaitStatusSuccess];
    } failure:nil];
    [operation start];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0f];
    
}
@end
```

## setup server

```objective-c
[NLTHTTPStubServer globalSettings].port = 12345;
server = [[NLTHTTPStubServer stubServer] retain];
[server startServer];
```

## stop server
```objective-c
[server stopServer];
[server release];
```

## create simple response
```objective-c
[[[server stub] forPath:@"/api.json"] andJSONResponse:json];
```

### support content-types
* JSON
* HTML
* XML
* Plain Text

## set status code
```objective-c
[[[server stub] forPath:@"/api.json"] andStatusCode:200];
```

## simulate timeout
```objective-c
[[[server stub] forPath:@"/api.json"] andTimeout];
```

## check query
```objective-c
[[[server stub] forPath:@"api.json"] andCheckURI:^(NSURL *URI) {
    // check URI
}];
```
