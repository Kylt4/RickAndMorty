//
//  RemoteCharacterItemMapper.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

final class RemoteCharacterItemMapper {
    static func map(_ data: Data) throws -> CharacterModel {
        let item = try JSONDecoder().decode(RemoteCharacter.self, from: data)
        return item.toApp
    }

    private init() {}

    private struct RemoteCharacter: Codable {
        let id: Int
        let name: String
        let status: String
        let species: String
        let type: String
        let gender: String
        let origin: RemoteLocationInfo
        let location: RemoteLocationInfo
        let image: URL
        let created: Date

        var toApp: CharacterModel {
            return CharacterModel(
                id: id,
                name: name,
                status: status,
                species: species,
                type: type,
                gender: gender,
                origin: LocationInfoItem(name: origin.name, url: origin.url),
                location: LocationInfoItem(name: location.name, url: location.url),
                image: image,
                created: created
            )
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.status = try container.decode(String.self, forKey: .status)
            self.species = try container.decode(String.self, forKey: .species)
            self.type = try container.decode(String.self, forKey: .type)
            self.gender = try container.decode(String.self, forKey: .gender)
            self.origin = try container.decode(RemoteLocationInfo.self, forKey: .origin)
            self.location = try container.decode(RemoteLocationInfo.self, forKey: .location)
            self.image = try container.decode(URL.self, forKey: .image)
            let stringCreated = try container.decode(String.self, forKey: .created)
            self.created = Date.fromISO8601(stringCreated)!
        }
    }

    private struct RemoteLocationInfo: Codable {
        let name: String
        let url: URL
    }
}
