//
//  CharacterItem.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public struct CharacterItem: Equatable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let type: String
    public let gender: String
    public let origin: LocationInfoItem
    public let location: LocationInfoItem
    public let image: URL
    public let created: Date

    public init(id: Int, name: String, status: String, species: String, type: String, gender: String, origin: LocationInfoItem, location: LocationInfoItem, image: URL, created: Date) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.origin = origin
        self.location = location
        self.image = image
        self.created = created
    }
}

public struct LocationInfoItem: Equatable {
    public let name: String
    public let url: URL

    public init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
