//
//  CookieManager.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-28.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation
import WebKit

class CookieManager {

    static func setCookies(_ cookies: [HTTPCookie], completion: @escaping () -> Void) {
        let domains = cookies.map { $0.domain }.uniqued()

        deleteCookiesForDomains(domains) {
            setHTTPStoreCookies(cookies)
            setWebsiteDataStoreCookies(cookies)
            completion()
        }
    }

    static func cookies(from cookieDictionaries: [[String: String]]) -> [HTTPCookie] {
        var httpCookies = [HTTPCookie]()

        for dictionary in cookieDictionaries {
            guard let domain = dictionary[Cookie.CodingKeys.domain.rawValue],
                  let key = dictionary[Cookie.CodingKeys.key.rawValue],
                  let value = dictionary[Cookie.CodingKeys.value.rawValue]
            else {
                TSMobileAnalytics.logger.log(
                    message: "Failed to parse cookie arguments.",
                    verbosity: .error)
                continue
            }

            guard let httpCookie = HTTPCookie(domain: domain, name: key, path: .slash, value: value)
            else { continue }

            httpCookies.append(httpCookie)
        }

        return httpCookies
    }

}

// MARK: - Private

private extension CookieManager {

    static func deleteCookiesForDomains(_ domains: [String], completion: @escaping () -> Void) {
        guard !domains.isEmpty,
              let storedCookies = HTTPCookieStorage.shared.cookies
        else { completion(); return }

        for cookie in storedCookies {
            for domain in domains {
                if domain.contains(cookie.domain) {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                    break
                }
            }
        }

        guard #available(iOS 11.0, *)
        else { completion(); return }
        
        DispatchQueue.main.async {
            let wkStore = WKWebsiteDataStore.default().httpCookieStore
            let dispatchGroup = DispatchGroup()

            dispatchGroup.enter()
    
            wkStore.getAllCookies { cookies in
                for cookie in cookies {
                    for domain in domains {
                        if domain.contains(cookie.domain) {
                            dispatchGroup.enter()
                            wkStore.delete(cookie) {
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }

    static func setHTTPStoreCookies(_ cookies: [HTTPCookie]) {
        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

    static func setWebsiteDataStoreCookies(_ cookies: [HTTPCookie]) {
        if #available(iOS 11.0, *) {
            for cookie in cookies {
                WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie)
            }
        }
    }

}
