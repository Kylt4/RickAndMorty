//
//  RetryView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 12/07/2025.
//

import SwiftUI

struct RetryView: View {
    private let onLoad: () -> Void

    init(onLoad: @escaping () -> Void) {
        self.onLoad = onLoad
    }

    var body: some View {
        Button(action: onLoad) {
            Image(systemName: "arrow.trianglehead.counterclockwise")
                .font(.largeTitle)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    @Previewable @State var retryCallCount = 0

    VStack(spacing: 50) {
        RetryView { retryCallCount += 1}
        Text("Retry called \(retryCallCount) times")
    }
}

