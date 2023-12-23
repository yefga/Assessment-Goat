//
//  URL.swift
//  Goat-Weather
//
//  Created by Yefga on 21/12/23.
//

import UIKit

public extension URL {
    var toUIImage: UIImage? {
        guard let data = try? Data(contentsOf: self) else {
            fatalError("URL Image not found")
        }
        return UIImage(data: data)
    }
}
