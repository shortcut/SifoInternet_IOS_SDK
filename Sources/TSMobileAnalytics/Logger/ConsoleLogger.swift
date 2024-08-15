//
//  ConsoleLogger.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-14.
//  Copyright © 2023 Kantar Sifo. All rights reserved.

import Foundation

class ConsoleLogger: Logger {
    var verbosity: Verbosity = .debug

    func log(message: @autoclosure @escaping () -> String, verbosity: Verbosity) {
        guard verbosity >= self.verbosity,
              verbosity != .silent
        else { return }

        print(message: message(), verbosity: verbosity)
    }

    func log(multipleLines: [String], verbosity: Verbosity) {
        guard verbosity >= self.verbosity,
              verbosity != .silent
        else { return }

        print(message: multipleLines.joined(separator: .newLine + .indentation), verbosity: verbosity)
    }
}

// MARK: - Private

private extension ConsoleLogger {
    func print(message: @autoclosure @escaping () -> String, verbosity: Verbosity) {
        Swift.print("\(String.newLine)\(verbosity.emoji)\(String.space)\(String.prefix)\(verbosity.rawValue.uppercased())\(String.colon)\(newLineIndentedMessage(from: message()))")
    }

    func newLineIndentedMessage(from message: String) -> String {
        return .newLine + .indentation + message
    }
}

private extension String {
    static let prefix = "Sifo SDK - "
}
