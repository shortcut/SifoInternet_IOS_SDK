//
//  JSONManager.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-30.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

class JSONManager {

    static func parseURLEncodedJSON(_ urlEncodedJsonString: String) -> [[String: String]]? {
        guard let withoutPercentEncoding = urlEncodedJsonString.removingPercentEncoding,
              let jsonData = withoutPercentEncoding.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: String]]
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to parse URL encoded JSON.",
                verbosity: .error)

            return nil
        }

        return jsonArray
    }

    static func urlEncodedJSON(from data: Data) -> String? {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              JSONSerialization.isValidJSONObject(dictionary),
              let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
              let string = String(data: jsonData, encoding: .utf8)?.urlEncoded()
        else {
            TSMobileAnalytics.logger.log(
                message: "Failed to convert data to JSON.",
                verbosity: .error)

            return nil
        }

        return string
    }

}
