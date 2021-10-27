//
//  File.swift
//  
//
//  Created by Karl Söderberg on 2021-10-15.
//

import Foundation
import TSMobileAnalyticsObjC
import WebKit

public enum TrackingType : UInt {

    case TrackUsersAndPanelists = 0

    case TrackPanelistsOnly = 1
    
    func toObjType() -> TSMobileAnalyticsObjC.TrackingType {
        TSMobileAnalyticsObjC.TrackingType(rawValue: self.rawValue)!
    }
}

open class TSMobileAnalytics : NSObject {

    /**
     * Designated framework initializer.
     * @param cpid The customer specific CPID provided the customer by TNS Sifo. Cannot be nil nor empty.
     * @param appName The unique application name to identify the app. Cannot be nil nor empty. Can be anything you like that makes sense.
     * @param trackingType Set to your appropriate tracking type.
     * @param webViewBased Set this to true if the application is primarily based on HTML/JavaScript running in web views
     * @param keychainAccessGroup set this to your keychain property, to share userId across applications with the same bundle seed.
     * @param additionals Set this to send any additional data to sync with panelist app.
     */
    open class func initialize(withCPID cpid: String,
                               applicationName appName: String,
                               trackingType: TrackingType,
                               enableSystemIdentifierTracking: Bool,
                               isWebViewBased webViewBased: Bool,
                               keychainAccessGroup: String?,
                               additionals: [String : String]?) {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.initialize(withCPID: cpid,
                                     applicationName: appName,
                                     trackingType: trackingType.toObjType(),
                                     enableSystemIdentifierTracking: enableSystemIdentifierTracking,
                                     isWebViewBased: webViewBased,
                                     keychainAccessGroup: keychainAccessGroup,
                                     additionals: additionals)
    }

    
    open class func initialize(withCPID cpid: String,
                               applicationName appName: String,
                               trackingType: TrackingType,
                               enableSystemIdentifierTracking: Bool,
                               isWebViewBased webViewBased: Bool,
                               keychainAccessGroup: String?) {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.initialize(withCPID: cpid,
                                     applicationName: appName,
                                     trackingType: trackingType.toObjType(),
                                     enableSystemIdentifierTracking: enableSystemIdentifierTracking,
                                     isWebViewBased: webViewBased,
                                     keychainAccessGroup: keychainAccessGroup)
    }

    
    open class func initialize(withCPID cpid: String,
                               applicationName appName: String,
                               trackingType: TrackingType,
                               enableSystemIdentifierTracking: Bool,
                               keychainAccessGroup: String?) {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.initialize(withCPID: cpid,
                                     applicationName: appName,
                                     trackingType: trackingType.toObjType(),
                                     enableSystemIdentifierTracking: enableSystemIdentifierTracking,
                                     keychainAccessGroup: keychainAccessGroup)
    }

    
    /**
     ** Enable logging.
     ** @param logPrintsActivated set this to YES to enable logging.
     */
    open class func setLogPrintsActivated(_ logPrintsActivated: Bool) {
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.setLogPrintsActivated(logPrintsActivated)
    }

    
    /**
     * Send a tag.
     * @param categories NSArray with string/s.
     * @param contentID Optional The contentID for the tag.
     * @param completionBlock Optional block to be executed on completion.
     */
    open class func sendTag(withCategories categories: [String],
                            contentID: String?,
                            completion completionBlock: ((Bool, Error?) -> Void)? = nil) {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.sendTag(withCategories: categories, contentID: contentID, completion: completionBlock)
    }

    /**
     * Send a tag.
     * @param categories NSArray with string/s.
     * @param contentID Optional The contentID for the tag.
     * @param completionBlock Optional block to be executed on completion.
     */
    open class func sendTag(withCategories categories: [String],
                            contentID: String?) {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.sendTag(withCategories: categories, contentID: contentID)
    }

    
    /**
     * This method needs to be implemented in your app's appdelegate method with the same name, if you wish to track a panelist.
     * Forward the openURL:-call to the framework.
     */
    open class func application(_ application: UIApplication,
                                open url: URL,
                                options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.application(application, open: url, options: options)
    }

    
    /**
     * Add webview to be part of the tracking.
     * Webview must be added for framework to be tracked properly.
     * Only add webviews that you actually want to track.
     */
    open class func addWebview(_ webview: WKWebView) {
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.addWebview(webview)
    }

    
    /**
     * Remove webview from the tracking.
     * Remove webview when the webview is completly removed from the view hierarchy (not just hidden).
     */
    open class func removeWebview(_ webview: WKWebView) {
        TSMobileAnalyticsObjC
            .TSMobileAnalytics.removeWebview(webview)
    }
}


