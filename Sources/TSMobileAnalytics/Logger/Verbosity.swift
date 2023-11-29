//
//  Verbosity.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-14.
//  Copyright © 2023 Kantar Sifo. All rights reserved.

import Foundation

public enum Verbosity: String {
    case debug
    case info
    case warning
    case error
    case critical
    case silent

    var emoji: String {
        switch self {
        case .silent:
            return ""
        case .debug:
            return "🕵️‍♀️"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "⛔️"
        case .critical:
            return "🔥"
        }
    }
}

// MARK: - Comparable

extension Verbosity: Comparable {
    public static func < (lhs: Verbosity, rhs: Verbosity) -> Bool {
        lhs.filterLevel < rhs.filterLevel
    }

    private var filterLevel: Int {
        switch self {
        case .debug:
            return 0
        case .info:
            return 1
        case .warning:
            return 2
        case .error:
            return 3
        case .critical:
            return 4
        case .silent:
            return 5
        }
    }
}
