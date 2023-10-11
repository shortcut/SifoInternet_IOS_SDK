//
//  Sequence+.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-28.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import Foundation

extension Sequence where Element: Hashable {
    /// Returns an array of elements with all duplicates removed.
    ///
    /// Does not retain the order of the elements.
    func uniqued() -> [Element] {
        return Array(Set(self))
    }
}
