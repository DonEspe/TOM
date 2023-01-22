//
//  TOMApp.swift
//  TOM
//
//  Created by Don Espe on 1/21/23.
//

import SwiftUI

@main
struct TOMApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: TOMDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
