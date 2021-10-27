import XCTest
@testable import TSMobileAnalytics

final class TSAnalyticsTests: XCTestCase {
        
    override func setUp() {
        TSMobileAnalytics.initialize(withCPID: "1111",
                                    applicationName: "tns.mobile-test",
                                    trackingType: .TrackUsersAndPanelists,
                                    enableSystemIdentifierTracking: false,
                                    keychainAccessGroup: nil)
    }
    
    func testSendTag() {
 
    }
}
