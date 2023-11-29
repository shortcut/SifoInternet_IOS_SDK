
import XCTest
@testable import TSMobileAnalytics

final class TSMobileAnalyticsTests: XCTestCase {

    // MARK: - slashSeparatedString

    func testSlashSeparatedStringOne() {
        let input = [String]()
        let expectedResult = 0
        let result = input.slashSeparatedString().count

        XCTAssert(result == expectedResult)
    }

    func testGenerateCategoryStringFromArrayTwo() {
        let input = ["one"]
        let expectedResult = "one"
        let result = input.slashSeparatedString()

        XCTAssert(result == expectedResult)
    }

    func testGenerateCategoryStringFromArrayThree() {
        let input = ["one", "two"]
        let expectedResult = "one/two"
        let result = input.slashSeparatedString()

        XCTAssert(result == expectedResult)
    }

    func testGenerateCategoryStringFromArrayFour() {
        let input = ["one", "two", "three"]
        let expectedResult = "one/two/three"
        let result = input.slashSeparatedString()

        XCTAssert(result == expectedResult)
    }

    func testGenerateCategoryStringFromArrayFive() {
        let input = ["one", "", "three"]
        let expectedResult = "one/three"
        let result = input.slashSeparatedString()

        XCTAssert(result == expectedResult)
    }

    // MARK: - parseURLEncodedJSONCookie

    func testParseURLEncodedJSONCookie() {
        let input = "%5B%7B%22key%22:%22openinsight%22,%22value%22:%22computerPan&PID=OS-PID-12345678&orvestoid=test1234&computerDbID=OS-DID-98765432&BID=OS-BID-00112233&measure=true%22,%22domain%22:%22.research-int.se%22,%22path%22:%22/%22%7D%5D"
        let array = JSONManager.parseURLEncodedJSON(input)
        guard let dictionary = array?[0] as? [String: String] else {
            XCTFail("Failed to get dictionary from JSON.")
            return
        }
        let expectedDictionary = [
            "key": "openinsight",
            "value": "computerPan&PID=OS-PID-12345678&orvestoid=test1234&computerDbID=OS-DID-98765432&BID=OS-BID-00112233&measure=true",
            "domain": ".research-int.se",
            "path": "/"
        ]

        XCTAssert(dictionary == expectedDictionary)
    }

    func testDecodingSyncResponse() {
        let testData: SyncResponse = try! TestData.SyncResponse.one.load()
        guard let cookie = testData.cookies.first
        else { XCTFail(); return }

        XCTAssert(!cookie.domain.isEmpty)
        XCTAssert(!cookie.key.isEmpty)
        XCTAssert(!cookie.value.isEmpty)
    }

    // MARK: - URLs

    func testInternalURLs() {
        let _ = URL.panelistAppUrl
        let _ = URL.appUrl
    }

    func testBaseURLs() {
        let _ = URL.sifoBaseURL
        let _ = URL.trafficGatewayBaseURL
    }

    func testSyncUrl() {
        let url = APIService().syncURL(sdkVersion: "one", appName: "two", json: "three")

        let expectedURL = URL(string: "https://sifopanelen.research-int.se/App/GetPanelistInfo?sdkversion=one&appname=two&SifoAppFrameworkInfo=three")!

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let expectedComponents = URLComponents(url: expectedURL, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(
            Set(components.queryItems!),
            Set(expectedComponents.queryItems!)
        )
    }

    func testSendTagURL() {
        let url = APIService().sendTagURL(
            cpid: "one",
            userID: "two",
            categoryString: "three",
            contentID: "four",
            appName: "five",
            reference: "six",
            isTrackingPanelistsOnly: true,
            isWebViewBased: true,
            appVersion: "seven",
            sdkVersion: "eight"
        )

        let expectedURL = URL(string: "https://trafficgateway.research-int.se/TrafficCollector?siteId=one&appClientId=two&cp=three&appId=four&appName=five&appRef=six&TrackPanelistsOnly=true&IsWebViewBased=true&appVersion=seven&session=sdk_eight")!

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let expectedComponents = URLComponents(url: expectedURL, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(
            Set(components.queryItems!),
            Set(expectedComponents.queryItems!)
        )
    }

}
