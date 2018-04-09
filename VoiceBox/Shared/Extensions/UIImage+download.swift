//
//  UIImage+download.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 3/30/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, callback: @escaping (() -> Void)) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                callback()
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, callback: @escaping (() -> Void)) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, callback: callback)
    }
}
