//
//  APIManager.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 23.06.2023.
//

import Foundation


protocol APIManagerDelegate {
    func didUpdateAPI(_ apiManager: APIManager, result: [ResultsModel])
    func didFailWithError( error: Error)
    func nothingFound()
}

protocol PlantApiManagerDelegate {
    func didUpdatePlantAPI(_ apiManager: APIManager, plant: PlantModel)
    func didFailWithError( error: Error)
    
}

struct APIManager {

    let idURL = "https://perenual.com/api/species-list?key=sk-vwOA6495d8e28a9071373"

    func fetchPlant(plantName: String?, id: Int?){
        
        if id != nil {
            let urlString = "https://perenual.com/api/species/details/\(id ?? 1)?key=sk-vwOA6495d8e28a9071373"
            performRequest(urlString: urlString, id: id)
        }else{
            guard let allowedPlantName = plantName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                fatalError("Space encoding into &20 failed")
            }
            let urlString = "\(idURL)&q=\(allowedPlantName)"
            performRequest(urlString: urlString, id: nil)
        }
    }
    
    var delegate: APIManagerDelegate?
    
    var plantDelegate: PlantApiManagerDelegate?
    
    func performRequest(urlString: String, id: Int?){
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if id != nil {
                    if let safeData = data {
                        guard let plant = self.parseJSON(plantData: safeData) else {
                            fatalError("Return plant from parse JSON not working")
                        }
                        self.plantDelegate?.didUpdatePlantAPI(self, plant: plant)
                    }
                }else{
                    if let safeData = data {
                        guard let result = self.parseJSON(queryData: safeData) else {
                            fatalError("Could not parse JSON")
                        }
                        if result.isEmpty {
                            DispatchQueue.main.async {
                                self.delegate?.nothingFound()
                            }
                        } else {
                            self.delegate?.didUpdateAPI(self, result: result)
                        }
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJSON(plantData: Data) -> PlantModel?{
        let decoder = JSONDecoder()
        
        do{
            let decodedData = try decoder.decode(PlantData.self, from: plantData)
            
            let bio = decodedData.description
            let watering = decodedData.watering
            let sunlight = decodedData.sunlight
            let growth = decodedData.growth_rate ?? "Unknown"
            let care = decodedData.care_level ?? "Unknown"
            var pets: String
            if decodedData.poisonous_to_pets == 0 {
                pets = "No"
            } else {
                pets = "Yes"
            }

            
            let plant = PlantModel(description: bio, watering: watering, sunlight: sunlight, growthRate: growth, careLevel: care, poisonsPets: pets)
            
            return plant
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func parseJSON(queryData: Data) -> [ResultsModel]?{
        let decoder = JSONDecoder()
        
        var searchRes: [ResultsModel]? = []
        do{
            let decodedData = try decoder.decode(QueryData.self, from: queryData)
            for results in decodedData.data{
                let id = results.id
                let commonName = results.common_name
                guard let scientificName = results.scientific_name?[0] else {
                    fatalError("Scientific name NIL at \(results.id)")
                }
                let defaultImage = results.default_image?.thumbnail ?? "https://i.ibb.co/vVjJFZb/Icon-4.png"
                let result = ResultsModel(id: id, commonName: commonName, scientificName: scientificName, defaultImage: defaultImage)
                searchRes?.append(result)
            }
        } catch {
            print("\(error) the error in parseJSON")
            DispatchQueue.main.async {
                self.delegate?.nothingFound()
            }
        }
        return searchRes
    }
    
}
