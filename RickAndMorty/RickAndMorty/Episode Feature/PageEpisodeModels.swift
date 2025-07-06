//
//  PageEpisodeModels.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public struct PageEpisodeModels: Equatable {
    public let info: PageInfo
    public let results: [EpisodeModel]

    public init(info: PageInfo, results: [EpisodeModel]) {
        self.info = info
        self.results = results
    }
}

public struct PageInfo: Equatable {
    public let count: Int
    public let pages: Int
    public let prev: URL?
    public let next: URL?

    public init(count: Int, pages: Int, prev: URL?, next: URL?) {
        self.count = count
        self.pages = pages
        self.prev = prev
        self.next = next
    }
}

public struct EpisodeModel: Equatable {
    public let id: Int
    public let name: String
    public let airDate: String
    public let episode: String
    public let episodeURL: URL
    public let created: Date
    public let characters: [URL]


    public init(id: Int, name: String, airDate: String, episode: String, episodeURL: URL, created: Date, characters: [URL]) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.episodeURL = episodeURL
        self.created = created
        self.characters = characters
    }
}
