//
//  ContentView.swift
//  TOM
//
//  Created by Don Espe on 1/21/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: TOMDocument

    var body: some View {
        NavigationSplitView {
            Text("Data")
        } detail: {
            VSplitView {
                TextEditor(text: $document.text)
                    .font(.system(size: 18).monospaced())
                    .scrollContentBackground(.hidden)
                    .padding()
                TextEditor(text: .constant("Output"))
                    .font(.system(size: 18).monospaced())
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(TOMDocument()))
    }
}
