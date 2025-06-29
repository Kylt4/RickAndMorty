//
//  SharedHelpers.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
