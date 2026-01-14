//
//  StatBadge.swift
//  Developer1
//

import SwiftUI

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(value)
                    .fontWeight(.semibold)
            }
            .font(.title2)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        StatBadge(icon: "arrow.triangle.branch", value: "5", label: "Commits")
        StatBadge(icon: "arrow.triangle.pull", value: "2", label: "PRs")
    }
    .padding()
}
