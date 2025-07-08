//
//  ErrorView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void

    @State private var errorIsVisible = false

    public init(errorMessage: String, onRetry: @escaping () -> Void) {
        self.errorMessage = errorMessage
        self.onRetry = onRetry
    }

    var body: some View {
        VStack {
            Text(errorMessage)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: errorIsVisible ? 80 : 0)
                .background(.red)
                .opacity(errorIsVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: errorIsVisible)
                .onAppear { errorIsVisible = true }
            Spacer()
        }
        .contentShape(.rect)
        .onTapGesture(perform: onRetry)
    }
}

#Preview {
    @Previewable @State var retryCallCount = 0

    VStack(spacing: 50) {
        ErrorView(errorMessage: "Any error message") {
            retryCallCount += 1
        }
        Text("Retry called \(retryCallCount) times")
    }
}
