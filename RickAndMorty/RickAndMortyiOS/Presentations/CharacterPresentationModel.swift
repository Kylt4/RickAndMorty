//
//  CharacterPresentationModel.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation

public struct CharacterPresentationModel {
    public let name: String
    public let status: String
    public let origin: String
    public let location: String
    public let loadImage: (() -> Void)

    public init(name: String, status: String, origin: String, location: String, loadImage: @escaping () -> Void) {
        self.name = name
        self.status = status
        self.origin = origin
        self.location = location
        self.loadImage = loadImage
    }
}
