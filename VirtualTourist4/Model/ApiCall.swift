//
//  ApiCall.swift
//  VirtualTourist4
//
//  Created by Pantos, Thomas on 7/4/23.
//

import Foundation


    class FlickrClient {
            static let APIKEY = "3b54ca3bce87cd0c26012d7d2185b5b5"
            static let baseURL = "https://api.flickr.com/services/rest"
        
        enum Endpoints {
            case photoSearch(Double, Double)
            
            var stringValue: String {
                switch self {
                case .photoSearch(let latitude, let longitude):
                    return "\(baseURL)/?method=flickr.photos.search&api_key=\(APIKEY)&lat=\(latitude)&lon=\(longitude)&per_page=30&page=1&format=json&nojsoncallback=1"
                }
            }
            
            var url: URL {
                return URL(string: stringValue)!
            }
        }
        
        
        
        
       class func searchPhotos(latitude: Double, longitude: Double, completion: @escaping ([String], Error?) -> Void) {
           var request = URLRequest(url: Endpoints.photoSearch(latitude, longitude).url)
           request.httpMethod = "GET"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                if let error = error {
//                    completion([], error)
//                    return
//                }
                
                guard let data = data else {
                    completion([], error)
                    return
                }
                let decoder = JSONDecoder()

                do {
                            let response = try decoder.decode(FlickrImageResponse.self, from: data)
                            let photos = response.photos.photo
                            
                            // Create an array of URLs from the photo objects
                            let urls = photos.map { photo in
                                let urlString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_w.jpg"
                                return urlString
                            }
                            
                            completion(urls, nil)
                        } catch {
                            completion([], error)
                        }
                    }
                    
                    task.resume()
                }

            
  
    
    class func downloadPhoto(url: String, completion: @escaping (Data) -> Void){
        let url = URL(string: url)
        
        if let url = url {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            task.resume()
        }
    }


}
