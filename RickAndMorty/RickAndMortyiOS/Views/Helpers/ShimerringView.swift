//
//  ShimerringView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import SwiftUI

struct ShimmerView: View {
    @State private var startPoint: UnitPoint = .zero
    @State private var endPoint: UnitPoint = .zero

    private var gradientColors = [
        Color.gray.opacity(0.2),
        Color.white.opacity(0.2),
        Color.gray.opacity(0.2)
    ]

    var body: some View {
        LinearGradient(colors: gradientColors,
                       startPoint: startPoint,
                       endPoint: endPoint)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: false)) {
                    startPoint = .init(x: 1, y: 1)
                    endPoint = .init(x: 2.2, y: 1.5)
                }
        }
    }
}

struct Shimmer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShimmerView()
                .preferredColorScheme(.light)
                .previewDisplayName("LIGHT")

            ShimmerView()
                .preferredColorScheme(.dark)
                .previewDisplayName("DARK")
        }
    }
}
