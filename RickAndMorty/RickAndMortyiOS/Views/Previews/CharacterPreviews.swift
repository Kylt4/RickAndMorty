//
//  CharacterPreviews.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 12/07/2025.
//

import SwiftUI

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewScrollView()
                .preferredColorScheme(.light)
                .previewDisplayName("PREVIEWS_LIGHT")

            PreviewScrollView()
                .preferredColorScheme(.dark)
                .previewDisplayName("PREVIEWS_DARK")
        }
    }
}

private struct PreviewScrollView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                PreviewView(displayName: "ItemWithImage",
                            content:                 PreviewCharacterViewBuilder.buildItemWithImage())

                PreviewView(displayName: "IsLoading",
                            content:                 PreviewCharacterViewBuilder.buildIsLoading())

                PreviewView(displayName: "ItemWithImageLoading",
                            content:                 PreviewCharacterViewBuilder.buildItemWithImageLoading())

                PreviewView(displayName: "ItemError",
                            content:                 PreviewCharacterViewBuilder.buildItemError())

                PreviewView(displayName: "ItemErrorImage",
                            content:                 PreviewCharacterViewBuilder.buildItemErrorImage())
            }
        }
    }
}

class PreviewCharacterViewBuilder {
    private static func makeItem() -> CharacterPresentationModel {
        return CharacterPresentationModel(name: "Rick", status: "🧡 Alive", origin: "Earth (C-137)", location: "Citadell of Ricks", loadImage: {})
    }

    private static func buildContainer() -> CharacterViewModelContainer {
        let imageViewModel = ImageViewModel {  _ in throw NSError() }
        let characterViewModel = CharacterViewModel { _ in throw NSError() }
        return CharacterViewModelContainer(
            characterViewModel: characterViewModel,
            imageViewModel: imageViewModel)
    }

    static func buildItemWithImage() -> CharacterView {
        let container = buildContainer()
        container.characterViewModel.item = makeItem()
        container.imageViewModel.item = UIImage.make(withColor: .red)
        return CharacterView(viewModel: container, onLoad: {})
    }

    static func buildItemWithImageLoading() -> CharacterView {
        let container = buildContainer()
        container.characterViewModel.item = makeItem()
        container.imageViewModel.isLoading = true
        return CharacterView(viewModel: container, onLoad: {})
    }

    static func buildIsLoading() -> CharacterView {
        let container = buildContainer()
        container.characterViewModel.isLoading = true
        return CharacterView(viewModel: container, onLoad: {})
    }

    static func buildItemError() -> CharacterView {
        let container = buildContainer()
        container.characterViewModel.errorMessage = "Any error message"
        return CharacterView(viewModel: container, onLoad: {})
    }

    static func buildItemErrorImage() -> CharacterView {
        let container = buildContainer()
        container.characterViewModel.item = makeItem()
        container.imageViewModel.errorMessage = "Any error message"
        return CharacterView(viewModel: container, onLoad: {})
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
