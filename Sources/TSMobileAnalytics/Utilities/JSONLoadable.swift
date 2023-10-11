//
//  JSONLoadable.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-27.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

public protocol JSONLoadable {
    var rawValue: String { get }
    func load<T: Decodable>() throws -> T
}

public extension JSONLoadable {
    func load<T: Decodable>() throws -> T {
        let data = try Data(contentsOf: Bundle.module.url(forResource: rawValue, withExtension: "json") ?? URL(fileURLWithPath: .empty))
        return try decoder.decode(T.self, from: data)
    }
}

fileprivate var decoder = JSONDecoder()

public enum TestData {
    public enum SyncResponse: String, JSONLoadable {
        case one = "SyncResponse"
    }

}
