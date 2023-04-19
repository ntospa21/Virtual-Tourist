//
//  FlickrImageResponse.swift
//  VirtualTourist4
//
//  Created by Pantos, Thomas on 7/4/23.
//

import Foundation

struct FlickrImageResponse : Codable {
    let photos : Photos
    
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Model]
}

struct Model: Codable {
    let id: String
    let owner: String
    let title: String
    let ispublic: Int
    let isfamily: Int
    let secret: String
    let isfriend: Int
    let server: String
}
