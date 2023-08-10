//
//  PlantData.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 24.06.2023.
//

import Foundation


struct PlantData: Codable {

    let description: String
    let watering: String
    let sunlight: [String]
    let growth_rate: String?
    let care_level: String?
    let poisonous_to_pets: Int
    
}

