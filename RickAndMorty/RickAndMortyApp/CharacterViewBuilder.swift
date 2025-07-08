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

    static func buildCharacterView(from url: URL, client: HTTPClient) -> CharacterView {
        let imageViewModel = ImageViewModel(mapper: UIImage.tryMake(_:))

        let characterViewModel = CharacterViewModel { item in
            return CharacterPresentationModel(
                name: item.name,
                status: item.status == "Alive" ? "🧡  Alive" : "☠️  Dead",
                origin: "🌍  \(item.origin.name.capitalized)",
                location: "📍  \(item.location.name.capitalized)",
                loadImage: loadImage(for: item.image, in: imageViewModel, client: client)
            )
        }

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

private class RemoteImageDataLoaderWithSomeFailure: ImageDataLoader {
    let decoratee: RemoteImageDataLoader

    init(decoratee: RemoteImageDataLoader) {
        self.decoratee = decoratee
    }

    public func load() async throws -> Data {
        if Int.random(in: 1...10) == 1 {
            throw NSError(domain: "any error", code: 0)
        } else {
            let random = TimeInterval.random(in: 0...1)
            try? await Task.sleep(for: .seconds(random))
            return try await decoratee.load()
        }
    }
}
