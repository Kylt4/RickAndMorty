//
//  CharacterViewBuilder.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import RickAndMorty
import RickAndMortyiOS
import SwiftUI

final class CharacterViewBuilder {
    private init() {}

    static func buildCharacterViewModel(imageViewModel: ImageViewModel, client: HTTPClient) -> CharacterViewModel {
        return CharacterViewModel { item in
            return CharacterPresentationModel(
                name: item.name,
                status: item.status == "Alive" ? "🧡  Alive" : "☠️  Dead",
                origin: "🌍  \(item.origin.name.capitalized)",
                location: "📍  \(item.location.name.capitalized)",
                loadImage: loadImage(for: item.image, in: imageViewModel, client: client)
            )
        }
    }

    static func buildCharacterView(from url: URL, characterViewModel: CharacterViewModel, imageViewModel: ImageViewModel, client: HTTPClient) -> CharacterView {
        let characterLoader = RemoteCharacterLoader(
            url: url,
            client: client
        )
        let characterAdapter = LoadResourcePresentationAdapter(
            loader: characterLoader,
            delegate: characterViewModel
        )

        return CharacterView(
            viewModel: CharacterViewModelContainer(
                characterViewModel: characterViewModel,
                imageViewModel: imageViewModel),
            onLoad: characterAdapter.load)
    }

    private static func loadImage(for url: URL, in viewModel: ImageViewModel, client: HTTPClient) -> (() -> Void) {
        return {
            let imageLoader = RemoteImageDataLoader(
                url: url,
                client: client
            )
            let imageLoaderDecorator = RemoteImageDataLoaderWithSomeFailure(decoratee: imageLoader)
            let imageAdapter = LoadResourcePresentationAdapter(
                loader: imageLoaderDecorator,
                delegate: viewModel
            )
            imageAdapter.load()
        }
    }
}
