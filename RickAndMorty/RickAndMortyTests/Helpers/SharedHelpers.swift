//
//  SharedHelpers.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation
import RickAndMorty

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyDate() -> Date {
    return Date(timeIntervalSince1970: 1751179947)
}

func anyEpisodeItem() -> EpisodeItem {
    EpisodeItem(id: Int.random(in: 0...Int.max), name: "any name", airDate: "any air date", episode: "any episode", episodeURL: anyURL(), created: anyDate(), characters: [anyURL()])
}

func pageInfo(prev: URL?, next: URL?) -> PageInfo {
    PageInfo(count: Int.random(in: 0...Int.max), pages: Int.random(in: 0...Int.max), prev: prev, next: next)
}

func anyPageEpisodeItems() -> PageEpisodeItems {
    return PageEpisodeItems(info: pageInfo(prev: nil, next: nil), results: [anyEpisodeItem()])
}

func waitForContinuation() async {
    try? await Task.sleep(for: .milliseconds(1))
}
