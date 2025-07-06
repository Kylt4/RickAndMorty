//
//  CharacterPresentationModel.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation

public struct CharacterPresentationModel: Equatable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let type: String
    public let gender: String
    public let origin: String
    public let location: String
    public let image: URL
    public let created: Date

    public init(id: Int, name: String, status: String, species: String, type: String, gender: String, origin: String, location: String, image: URL, created: Date) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.image = image
        self.origin = origin
        self.location = location
        self.created = created
    }
}
