//
//  ViewModels.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import RickAndMorty
import UIKit

// MARK: - Episodes

public typealias EpisodesViewModel = LoadResourceViewModel<PageEpisodeModels, EpisodesPresentationModel>

// MARK: - Character

public typealias CharacterViewModel = LoadResourceViewModel<CharacterModel, CharacterPresentationModel>
public typealias ImageViewModel = LoadResourceViewModel<Data, UIImage>

public class CharacterViewModelContainer {
    let characterViewModel: CharacterViewModel
    let imageViewModel: ImageViewModel

    public init(characterViewModel: CharacterViewModel, imageViewModel: ImageViewModel) {
        self.characterViewModel = characterViewModel
        self.imageViewModel = imageViewModel
    }
}

