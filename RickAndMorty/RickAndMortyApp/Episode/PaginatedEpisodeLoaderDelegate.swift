//
//  PaginatedEpisodeLoaderDelegate.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty
import RickAndMortyiOS

final class PaginatedEpisodeLoaderDelegate: LoadEpisodeDelegate {
    var viewModel: EpisodesViewModel
    var oldItem: PageEpisodeModels

    init(viewModel: EpisodesViewModel, oldItem: PageEpisodeModels) {
        self.viewModel = viewModel
        self.oldItem = oldItem
    }

    func didStartLoading() {}

    func didFinishLoading(with item: PageEpisodeModels) {
        viewModel.didFinishLoading(
            with: PageEpisodeModels(info: item.info,
                                    results: oldItem.results + item.results)
        )
    }

    func didFinishLoading(with error: any Error) {}
}
