//
//  EpisodePreviews.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 12/07/2025.
//

import SwiftUI

struct EpisodeView_Previews: PreviewProvider {
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
                PreviewView(displayName: "XSMALL",
                            content: PreviewEpisodeViewBuilder.buildEpisodeView()
                    .dynamicTypeSize(.xSmall)
                )

                PreviewView(displayName: "MEDIUM",
                            content: PreviewEpisodeViewBuilder.buildEpisodeView()
                    .dynamicTypeSize(.medium)
                )

                PreviewView(displayName: "XXLARGE",
                            content: PreviewEpisodeViewBuilder.buildEpisodeView()
                    .dynamicTypeSize(.xxLarge)
                )
            }
        }
    }
}

private class PreviewEpisodeViewBuilder {
    private static func anyURL(id: Int) -> URL {
        return URL(string: "http://any-url-id\(id).com")!
    }

    static func buildEpisodeView() -> some View {
        return EpisodeView(episode:
                            EpisodePresentationModel(
                                name: "Episode 1",
                                characters: [anyURL(id: 0), anyURL(id: 1), anyURL(id: 2), anyURL(id: 3), anyURL(id: 4)]),
                           characterView: { _ in PreviewCharacterViewBuilder.buildItemWithImage() })
    }
}
