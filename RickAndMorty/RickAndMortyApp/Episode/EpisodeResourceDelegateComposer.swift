//
//  EpisodeResourceDelegateComposer.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty
import RickAndMortyiOS

protocol LoadEpisodeDelegate: LoadResourceDelegate where Item == PageEpisodeModels {}
extension EpisodesViewModel: LoadEpisodeDelegate {}

final class EpisodeResourceDelegateComposer: LoadEpisodeDelegate {
    private let delegates: [any LoadEpisodeDelegate]

    init(delegates: [any LoadEpisodeDelegate]) {
        self.delegates = delegates
    }

    func didStartLoading() {
        delegates.forEach { $0.didStartLoading() }
    }

    func didFinishLoading(with error: Error) {
        delegates.forEach { $0.didFinishLoading(with: error) }
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        delegates.forEach { $0.didFinishLoading(with: item) }
    }
}
