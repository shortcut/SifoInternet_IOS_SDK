//
//  TNSTaggingTests.m
//  TNSTaggingTests
//
//  Created by Johanna Sinkkonen on 10/02/16.
//  Copyright © 2016 Dynamo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSMobileAnalytics.h"

@interface TSMobileAnalyticsTests : XCTestCase

@property (nonatomic) TSMobileAnalytics *frameworkInstance;

@end

// An interface to allow us to access hidden members of TSMobileAnalytics
@interface TSMobileAnalytics ()
+ (NSString *)generateCategoryStringFromArray:(NSArray *)categories;
+ (NSArray  * _Nullable)parseURLEncodedJSONCookie:(NSString *)urlEncodedJsonString;
@end

@implementation TSMobileAnalyticsTests

- (void)setUp {
    [super setUp];
    NSLog(@"setup: %@", NSStringFromClass(self.class));
    self.frameworkInstance = [TSMobileAnalytics createInstanceWithCPID:@"1111" applicationName:@"tns.mobile-test" trackPanelist:false keychainAccessGroup:nil];
    XCTAssertNotNil(self.frameworkInstance, @"Framework initialization failed, instance is nil.");
}

- (void)tearDown {
    [super tearDown];
}

//- (void)testValidateInputParameters {
//    int result = [TSMobileAnalytics validateInputParametersWithCategory:@"aCategory" extra:@"extraString" contentID:@"someContentId" contentName:@"someContentName"];
//    XCTAssertLessThan(result, 1);
//}

- (void)testSendTag {
    XCTestExpectation *expectation = [self expectationWithDescription:@"success"];
    [TSMobileAnalytics sendTagWithCategories:@[@"aCategory"] contentName:@"someContentName" contentID:@"someContentId" completion:^(BOOL success, NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void) testGenerateCategoryStringFromArray {
    XCTAssertTrue([[TSMobileAnalytics generateCategoryStringFromArray:@[]] length] == 0);
    XCTAssertTrue([[TSMobileAnalytics generateCategoryStringFromArray:@[@"foo"]]  isEqualToString:@"foo"]);
    XCTAssertTrue([[TSMobileAnalytics generateCategoryStringFromArray:(@[@"foo", @"bar"])] isEqualToString: @"foo/bar"]);
    XCTAssertTrue([[TSMobileAnalytics generateCategoryStringFromArray:(@[@"foo", @"bar", @"baz"])] isEqualToString: @"foo/bar/baz"]);
    XCTAssertTrue([[TSMobileAnalytics generateCategoryStringFromArray:(@[@"foo", @"", @"bar"])] isEqualToString: @"foo/bar"]);
}

-(void)testParseJSONEncodedCookie {
    NSString *input = @"%5B%7B%22key%22:%22openinsight%22,%22value%22:%22computerPan&PID=OS-PID-12345678&orvestoid=test1234&computerDbID=OS-DID-98765432&BID=OS-BID-00112233&measure=true%22,%22domain%22:%22.research-int.se%22,%22path%22:%22/%22%7D%5D";

    NSArray *result = [TSMobileAnalytics parseURLEncodedJSONCookie:input];
    NSDictionary *expected = @{@"key":@"openinsight", @"value": @"computerPan&PID=OS-PID-12345678&orvestoid=test1234&computerDbID=OS-DID-98765432&BID=OS-BID-00112233&measure=true", @"domain": @".research-int.se", @"path": @"/" };
    XCTAssertNotNil(result);
    XCTAssertTrue([result[0][@"key"] isEqualToString:@"openinsight"]);
    XCTAssertTrue([result[0] isEqualToDictionary: expected]);
 }

@end
