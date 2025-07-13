//
//  FirebaseEpisodeTracker.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty

final class FirebaseTracker: LoadEpisodeDelegate {
    func didStartLoading() {
        print("[FIREBASE] - TRACKING: Start loading episodes")
    }
    
    func didFinishLoading(with error: Error) {
        print("[FIREBASE] - TRACKING: Finish loading episodes with \(error.localizedDescription)")
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        print("[FIREBASE] - TRACKING: Finish loading episodes with \(item.results.count)")
    }
}
