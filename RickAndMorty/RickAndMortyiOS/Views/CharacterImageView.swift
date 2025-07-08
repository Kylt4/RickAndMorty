//
//  CharacterImageView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import SwiftUI
import RickAndMorty

public struct CharacterImageView: View {
    private let viewModel: ImageViewModel
    private let onLoad: () -> Void

    public init(viewModel: ImageViewModel, onLoad: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onLoad = onLoad
    }

    public var body: some View {
        ZStack {
            if let image = viewModel.item {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if viewModel.errorMessage != nil {
                RetryView(onLoad: onLoad)
            } else {
                ShimmerView()
                    .onAppear(perform: onLoad)
            }
        }
    }
}
