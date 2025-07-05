//
//  LoadEpisodePresenter.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

public protocol LoadEpisodeDelegate {
    func didStartLoading()
    func didFinishLoading(with error: Error)
    func didFinishLoading(with item: PageEpisodeItems)
}

public final class LoadEpisodePresenter {
    private let delegate: LoadEpisodeDelegate
    private let loader: EpisodeLoader
    private var isLoading = false

    public init(delegate: LoadEpisodeDelegate, loader: EpisodeLoader) {
        self.delegate = delegate
        self.loader = loader
    }

    public func loadEpisodes() {
        guard !isLoading else { return }

        delegate.didStartLoading()
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                let item = try await loader.load()
                delegate.didFinishLoading(with: item)
            } catch {
                delegate.didFinishLoading(with: error)
            }
        }
    }
}
