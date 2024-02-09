//
//  Divider.swift
//  Moonshot
//
//  Created by Benedict Neo on 2/8/24.
//

import SwiftUI

struct Divider: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(.lightBackground)
            .padding(.vertical)
    }
}

#Preview {
    Divider()
        .preferredColorScheme(.dark)
}
