//
//  SendTagError.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-04-03.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

enum SendTagError: Error {
    case combinedCategoriesTooLong
    case contentIDTooLong
}

extension SendTagError: CustomStringConvertible {
    var description: String {
        switch self {
        case .combinedCategoriesTooLong:
            return "Combined length of categories is too long."
        case .contentIDTooLong:
            return "Content ID is too long."
        }
    }
}
