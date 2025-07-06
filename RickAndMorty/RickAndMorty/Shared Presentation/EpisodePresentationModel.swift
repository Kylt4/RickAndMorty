//
//  EpisodePresentationModel.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation

public struct EpisodePresentationModel: Equatable {
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
