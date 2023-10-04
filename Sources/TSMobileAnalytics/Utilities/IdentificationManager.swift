//
//  IdentificationManager.swift
//  TSMobileAnalytics
//
//  Created by Andreas Lif on 2023-03-23.
//  Copyright © 2023 Kantar Sifo. All rights reserved.
//

import AdSupport
import Foundation
import UIKit

class IdentificationManager {
    
    static let shared = IdentificationManager()
    private(set) var isSystemIdentifierTrackingEnabled = false

    var advertisingIdentifier: UUID? {
        guard isSystemIdentifierTrackingEnabled
        else { return nil }

        let uuid = ASIdentifierManager.shared().advertisingIdentifier

        guard uuid.uuidString != .uuidZeroString
        else { return nil }

        return uuid
    }

    var vendorIdentifier: UUID? {
        guard isSystemIdentifierTrackingEnabled
        else { return nil }

        return UIDevice.current.identifierForVendor
    }

    func setIsSystemIdentifiterTrackingEnabled(_ isEnabled: Bool) {
        isSystemIdentifierTrackingEnabled = isEnabled

        if !isEnabled {
            TSMobileAnalytics.logger.log(
                message: "IDFA and IDFV tracking turned off.",
                verbosity: .info)
        }
    }
}

// MARK: - Private

private extension String {
    static let uuidZeroString = "00000000-0000-0000-0000-000000000000"
}
