//
//  CharactersView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI
import RickAndMorty

public struct CharacterView: View {
    @ScaledMetric var cardWidth: CGFloat = 220

    private let characterViewModel: CharacterViewModel
    private let imageViewModel: ImageViewModel

    private let onLoad: () -> Void

    public init(viewModel: CharacterViewModelContainer, onLoad: @escaping () -> Void) {
        self.characterViewModel = viewModel.characterViewModel
        self.imageViewModel = viewModel.imageViewModel
        self.onLoad = onLoad
    }

    public var body: some View {
        ZStack {
            if let item = characterViewModel.item {
                VStack {
                    CharacterImageView(viewModel: imageViewModel, onLoad: item.loadImage)
                        .frame(width: cardWidth, height: cardWidth)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                    Text(item.name)
                        .font(.title2).bold()
                        .lineLimit(1)

                    VStack(alignment: .leading) {
                        Text(item.status)
                        Text(item.origin)
                        Text(item.location)
                    }
                    .font(.title3)
                    .lineLimit(1)
                    .frame(width: cardWidth, alignment: .leading)
                }
            } else if characterViewModel.errorMessage != nil {
                RetryView(onLoad: onLoad)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear(perform: onLoad)
            }
        }
        .frame(width: cardWidth)
        .frame(minHeight: cardWidth * 1.3)
    }
}
