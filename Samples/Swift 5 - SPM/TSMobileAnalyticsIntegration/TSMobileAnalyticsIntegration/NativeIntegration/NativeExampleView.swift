//
//  NativeExampleView.swift
//  NativeIntegration
//
//  Created by Karl Söderberg on 2023-10-04.
//  Copyright © 2023 TNS Sifo AB. All rights reserved.
//

import SwiftUI
import TSMobileAnalytics

struct ExampleView: View {
    var body: some View {
        Button("Send tag", action: sendTag)
            .onAppear(perform: sendTag)
    }
    
    func sendTag() {
        TSMobileAnalytics.sendTag(withCategories: ["category-testios"],
                                  contentID: "123-contentID") { (success, error) in
            if let tError = error {
                // Handle error.
                print("Error: \(tError.localizedDescription)")
            }
        }
    }
}
