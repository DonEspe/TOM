//
//  RegisterView.swift
//  TOM
//
//  Created by Don Espe on 1/22/23.
//

import SwiftUI

struct RegisterView: View {
    var name: String
    var value: Int
    var style: AnyGradient

    var body: some View {
        Text("\(name): \(binaryValue)")
            .bold()
            .monospaced()
            .padding(5)
            .frame(maxWidth: .infinity)
            .background(style)
            .clipShape(Capsule())
    }

    var binaryValue: String {
        if name == "ZX" {
            return String(value)
        } else {
            let baseBinary = String(value, radix: 2)
            return String(repeating: "0", count: 8 - baseBinary.count) + baseBinary
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(name: "AX", value: 127, style: Color.blue.gradient)
    }
}
