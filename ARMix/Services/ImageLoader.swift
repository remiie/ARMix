//
//  ImageLoader.swift
//  ARMix
//
//  Created by Роман Васильев on 01.05.2023.
//

import UIKit
import Foundation

enum URLs: String {
    case marker = "https://mix-ar.ru/content/ios/marker.jpg"
    var urlString: String { return self.rawValue }
}

final class ImageLoader {

    private init() { }
    static let shared = ImageLoader()
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}

extension ImageLoader {

}

