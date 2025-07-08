//
//  EpisodePresentationModel.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation

public struct EpisodesPresentationModel {
    public var episodes: [EpisodePresentationModel]
    public let loadMore: (() -> Void)?

    public init(episodes: [EpisodePresentationModel], loadMore: (() -> Void)?) {
        self.episodes = episodes
        self.loadMore = loadMore
    }
}

public struct EpisodePresentationModel: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let characters: [URL]

    public init(name: String, characters: [URL]) {
        self.id = name
        self.name = name
        self.characters = characters
    }
}
