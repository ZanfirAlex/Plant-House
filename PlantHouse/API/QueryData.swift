//
//  QueryData.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 23.06.2023.
//

import Foundation

struct QueryData: Codable {
    let data: [data]
}


struct data: Codable {
    
    let id: Int
    let common_name: String
    let scientific_name: [String]?
    let default_image: Default_Image?
  
}

struct Default_Image: Codable {
    let thumbnail : String?
}
