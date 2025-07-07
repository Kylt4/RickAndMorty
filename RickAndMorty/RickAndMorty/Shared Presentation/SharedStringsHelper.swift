//
//  SharedStringsHelper.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation

class SharedStringsHelper {
    private init() {}

    static var loadError: String {
        String(localized: "GENERIC_CONNECTION_ERROR",
               table: "Shared",
               bundle: Bundle(for: Self.self))
    }
}
