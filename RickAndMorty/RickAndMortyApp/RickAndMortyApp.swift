//
//  RickAndMortyApp.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI
import RickAndMorty
import RickAndMortyiOS

@main
struct RickAndMortyApp: App {
    private let client: HTTPClient = URLSessionHTTPClient(session: .shared)
    private let cacheView = CharacterCacheView()

    var body: some Scene {
        WindowGroup {
            EpisodesViewBuilder.build(
                client: client,
                characterView: { url in
                    cacheView.view(for: url, client: client)
                }
            )
        }
    }
}

final class CharacterCacheView {
    private let cache = NSCache<NSString, CacheViewModelContainer>()

    func view(for url: URL, client: HTTPClient) -> CharacterView {
        let nsStringURL = NSString(string: url.absoluteString)

        if let container = cache.object(forKey: nsStringURL) {
            return CharacterViewBuilder.buildCharacterView(from: url, characterViewModel: container.characterViewModel, imageViewModel: container.imageViewModel, client: client)
        }

        let imageViewModel = ImageViewModel(mapper: UIImage.tryMake(_:))
        let characterViewModel = CharacterViewBuilder.buildCharacterViewModel(imageViewModel: imageViewModel, client: client)

        cache.setObject(CacheViewModelContainer(characterViewModel: characterViewModel, imageViewModel: imageViewModel), forKey: nsStringURL)
        return CharacterViewBuilder.buildCharacterView(from: url, characterViewModel: characterViewModel, imageViewModel: imageViewModel, client: client)
    }

    private class CacheViewModelContainer {
        let characterViewModel: CharacterViewModel
        let imageViewModel: ImageViewModel

        init(characterViewModel: CharacterViewModel, imageViewModel: ImageViewModel) {
            self.characterViewModel = characterViewModel
            self.imageViewModel = imageViewModel
        }
    }
}
