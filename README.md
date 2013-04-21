# NLTHTTPStubServer

[Japanese]()

Fake server for iOS testing.

Can register fake response by `expect` or `stub`.

```Objetive-C
[[[server expect] forPath:@"/api/"] andJSONResponseResource:@"fake-response" ofType:@"json"];
```

# Getting Ready

* With [CocoaPods](https://github.com/CocoaPods/).

Podfile:
```ruby
pod 'NLTHTTPStubServer'
```

* Import `NLTHTTPStubServer.h` at top of your TestCase.

# First Step

The most simply example with GHUnit async test case.
Servers URL is `localhost:12345` on default.

```objective-c
- (void)testMostSimply {
    
    // Get shared server instance.
    server = [NLTHTTPStubServer sharedServer];

    // Register fake response for localhost:12345/fake
    NSData *data = [@"RESPONSE" dataUsingEncoding:NSUTF8StringEncoding];
    [[[server expect] forPath:@"/fake"] andPlainResponse:data];
    
    // GHUnit: Setup async test
    [self prepare];

    // Access to localhost:12345/fake
    __weak id that = self;
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:12345/fake"]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {

                                // Getting a fake response!
                                GHAssertEqualStrings(toString(data), @"RESPONSE", nil);

                                // GHUnit: notify!
                               [that notify:kGHUnitWaitStatusSuccess];
                           
                           }];
    
    // GHUnit: wait for status...
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10];

    // Invoked all expects?
    [server verify];
}
```

# Next Step

## Get a server instance and clear

Get shared instance.

```objective-c
NLTHTTPStubServer *server =[NLTHTTPStubServer sharedServer];
```

Remove all fake responses.

```objective-c
[server clear];
```

## Expecations and verifycation

```objective-c
[[server expect] forPath:@"/fake"];
```

Register fake response. Server will response this fake if requested `/fake`.
After this setup the functionality under test should be invoked followed by

```objective-c
[server verify];
```

When expected response has not been invoked, verify method will raise an exception.

## Stubs

```objective-c
[[server stub] forPath:@"/fake"]
```

`stub` is like `expect`, But `stub` is existing if invoked it. 
`verify` ignores response that registered by `stub`.

# Features

## NLTPath

`NLTPath` generate complicated path.
For example, This request has two GET parameters.

```objective-c
[[server expect] forPath:[NLTPath pathWithPathString:@"/fake" andParameters:@{
        @"k1" : @"v1",
        @"k2" : @"v2",
}]];
```

This request can matches `/fake?k1=v1&k2=v2` or `/fake?k2=v2&k1=v1`.

### anyValue

Can use `[NLTPath anyValue]` to parameters value.

```objective-c
[[server expect] forPath:[NLTPath pathWithPathString:@"/fake" andParameters:@{
        @"k1" : [NLTPAth anyValue]
}]];
```

This request can matches `/fake?k1=hogeeeeeeee`, `/fake?k1=fugaaaaaaaaaa` and mores.


## HTTP Method

```objective-c
[[server stub] forPath:@"/fake" HTTPMethodPost];
```

## Status code

```objective-c
[[[server stub] forPath:@"/fake"] andStatusCode:200];
```

## Simulate waiting

```objective-c
[[[server stub] forPath:@"/fake"] andProcessingTime:10.0f];
```

## Checking POST body

```objective-c
[[[server expect] forPath:@"/fake" HTTPMethod:@"POST"] andCheckPostBody:^(NSData *postBody) {
        NSString *postBodyString = [that toString:postBody];
        GHAssertEqualStrings(postBodyString, @"POST_BODY", nil);
    }];
```

## Supporting content-types

```objective-c
[[[server expect] forPath:@"/fake"] and{ContentType}Response...]
```

* JSON
* HTML
* XML
* Plain Text
* Binary
  * application/octet-stream

