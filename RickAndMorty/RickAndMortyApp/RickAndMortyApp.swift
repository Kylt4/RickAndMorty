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
    private let cacheView = CharacterViewCache()

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

final class CharacterViewCache {
    private var cache: [URL: CharacterView] = [:]

    func view(for url: URL, client: HTTPClient) -> CharacterView {
        if let view = cache[url] {
            return view
        }

        let view = CharacterViewBuilder.buildCharacterView(from: url, client: client)
        cache[url] = view
        return view
    }
}
