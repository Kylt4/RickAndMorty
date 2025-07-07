//
//  CharactersView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI
import RickAndMorty

public typealias CharacterViewModel = LoadResourceViewModel<CharacterModel, CharacterPresentationModel>

struct CharacterView: View {
    var viewModel: CharacterViewModel

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 150)
            VStack(spacing: 4) {
                Text(viewModel.item?.name ?? "Hello world!")
                    .font(.title3).bold()
                HStack {
                    Text("☠️")
                    Text("Dead - Human")
                }
                HStack {
                    Text("🌍")
                    Text("Citadel of Ricks")
                }
                HStack {
                    Text("📸")
                    Text("The ricklantis Mixup")
                }
            }.font(.callout)
        }
    }
}

//struct CharactersView: View {
//    @Environment(\.colorScheme) var colorScheme
//    var characterURLs: [URL]
//
//    var characterViewModel: (URL) -> CharacterViewModel
//
//    private var colorShadow: Color {
//        Color(colorScheme == .dark ? .white : .black)
//    }
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 16) {
//                ForEach(characterURLs, id: \.self) { url in
//                    CharacterView(viewModel: characterViewModel(url))
//                        .padding()
//                        .background(Color(.tertiarySystemBackground))
//                        .cornerRadius(16)
//                        .shadow(color: colorShadow.opacity(0.3), radius: 5, y: 2)
//                }
//            }
//            .padding()
//        }
//    }
//}
