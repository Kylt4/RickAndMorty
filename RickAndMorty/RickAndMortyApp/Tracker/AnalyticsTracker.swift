//
//  AnalyticsTracker.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty

class AnalyticsTracker: LoadEpisodeDelegate {
    func didStartLoading() {
        print("[ANALYTICS] - TRACKING: Start loading episodes")
    }

    func didFinishLoading(with error: Error) {
        print("[ANALYTICS] - TRACKING: Finish loading episodes with \(error.localizedDescription)")
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        print("[ANALYTICS] - TRACKING: Finish loading episodes with \(item.results.count)")
    }
}
