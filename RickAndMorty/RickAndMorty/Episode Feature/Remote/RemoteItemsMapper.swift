//
//  RemoteItemsMapper.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

struct RemotePageEpisodeItems: Decodable, Equatable {
    let info: RemotePageInfo
    let results: [RemoteEpisodeItem]

    var toLocal: PageEpisodeItems {
        return PageEpisodeItems(
            info: PageInfo(count: info.count,
                           pages: info.pages,
                           prev: info.prev,
                           next: info.next),
            results: results.map { item in
                EpisodeItem(id: item.id,
                            name: item.name,
                            airDate: item.airDate,
                            episode: item.episode,
                            episodeURL: item.episodeURL,
                            created: item.created,
                            characters: item.characters)
            }
        )
    }
}

struct RemotePageInfo: Decodable, Equatable {
    let count: Int
    let pages: Int
    let prev: URL?
    let next: URL?
}

struct RemoteEpisodeItem: Decodable, Equatable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let episodeURL: URL
    let created: Date
    let characters: [URL]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
        case created
    }

    init(id: Int, name: String, airDate: String, episode: String, episodeURL: URL, created: Date, characters: [URL]) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.episodeURL = episodeURL
        self.created = created
        self.characters = characters
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.airDate = try container.decode(String.self, forKey: .airDate)
        self.episode = try container.decode(String.self, forKey: .episode)
        self.characters = try container.decode([URL].self, forKey: .characters)
        self.episodeURL = try container.decode(URL.self, forKey: .url)
        let stringCreated = try container.decode(String.self, forKey: .created)
        self.created = Date.fromISO8601(stringCreated)!
    }
}
