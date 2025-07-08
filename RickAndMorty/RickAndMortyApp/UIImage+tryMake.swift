//
//  UIImage+tryMake.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import UIKit

extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(_ data: Data) throws -> UIImage {
        if let image = UIImage(data: data) {
            return image
        } else {
            throw InvalidImageData()
        }
    }
}
