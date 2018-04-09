//
//  SearchImagesAPI.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 3/30/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import Alamofire

//struct SearchImagesParam {
//    var searchParam: String
//}

class SearchImagesAPI {
    
    struct API {
        static let baseUrl = "https://api.cognitive.microsoft.com/bing/v7.0/images/search"
        static let genericParams: Parameters = ["mkt":"en-us HTTP/1.1","safeSearch":"strict","imageType":"Clipart","count":"5"]
        static let genericHeaders: HTTPHeaders = ["Ocp-Apim-Subscription-Key":"ca10711d92c54e78b3d6c11154c5b2c1"]
        static let queryParamName = "q"
    }
    
    static func searchImages(_ queryParam: String, callback: @escaping ((UIImage?) -> Void) ) {
        
        var params = API.genericParams
        params[API.queryParamName] = queryParam
        
        Alamofire.request(API.baseUrl, parameters: params, headers: API.genericHeaders).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let dict = value as? [String:Any], let results = dict["value"] as? [[String: Any]], let imgLink = results[0]["contentUrl"] as? String {
                    let imageView = UIImageView()
                    imageView.downloadedFrom(link: imgLink.replacingOccurrences(of: "http:", with: "https:"), callback: {
                        callback(imageView.image)
                    })
                } else {
                    callback(nil)
                }
            case .failure(let error):
                print("error searching for image: \(error)")
                callback(nil)
            }
        }
    }
}

