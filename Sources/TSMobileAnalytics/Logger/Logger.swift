//
//  Logger.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-14.
//  Copyright © 2023 Kantar Sifo. All rights reserved.

import Foundation

public protocol Logger {
    var verbosity: Verbosity { get set }

    func log(message: @autoclosure @escaping () -> String, verbosity: Verbosity)
    func log(multipleLines: [String], verbosity: Verbosity)
}
