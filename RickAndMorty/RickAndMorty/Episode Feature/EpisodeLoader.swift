//
//  EpisodeLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public protocol EpisodeLoader {
    func load() async throws -> PageEpisodeItems
}
