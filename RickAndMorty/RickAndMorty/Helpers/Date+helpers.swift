//
//  Date+helpers.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public extension Date {
    var iso8601: String {
        Date.isoFormatter.string(from: self)
    }

    static func fromISO8601(_ string: String) -> Date? {
        return isoFormatter.date(from: string)
    }

    private static var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone, .withFractionalSeconds]
        formatter.timeZone = .current
        return formatter
    }()
}
