//
//  SearchProfileViewController.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 24.06.2023.
//

import Foundation
import UIKit
import CoreData

class SearchProfileViewController: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var poisonLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sciNameLabel: UILabel!
    @IBOutlet weak var growthRateLabel: UILabel!
    @IBOutlet weak var careLevelLabel: UILabel!
    @IBOutlet weak var sunlightLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var bio: UILabel!
    
    var apiPlantManager = APIManager()
    
    var water: String = ""
    var sunlight: String = ""
    var careLevel: String = ""
    var growthRate: String = ""
    var poisonsPets: String = ""
    
    
    var searchResult: ResultsModel?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maskView.isHidden = false
        
        apiPlantManager.plantDelegate = self
        
        apiPlantManager.fetchPlant(plantName: nil, id: searchResult?.id)
        
        loadDetails()
        
    }
    
    
    
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        let newPlant = Plant(context: self.context)
        newPlant.name = nameLabel.text
        newPlant.sciName = sciNameLabel.text
        newPlant.nickname = "Nickname"
        newPlant.bio = bio.text
        newPlant.watering = water
        newPlant.sun = sunlight
        newPlant.careLevel = careLevel
        newPlant.growthRate = growthRate
        newPlant.poison = poisonsPets
        guard let imageData = profileImage.image?.jpegData(compressionQuality: 1.0)else {
            fatalError("Error at converting jpeg into binary data")
        }
        
        newPlant.image = imageData
        
        self.saveItems()
        
        sender.setTitle(" Plant has been added", for: .disabled)
        sender.setImage(UIImage(systemName: "checkmark"), for: .disabled)
        sender.setTitleColor(UIColor(named: "PlantHouse Green"), for: .disabled)
        sender.tintColor = UIColor(named: "PlantHouse Green")
        sender.isEnabled = false
        
        let alert = UIAlertController(title: "Plant added to My Plants", message: "Plant has been added succesfully, you can now find it in My Plants!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    
    
    
    func loadDetails() {
        
        nameLabel.text = searchResult?.commonName.capitalized
        sciNameLabel.text = searchResult?.scientificName.capitalized
        
        guard let image = searchResult?.defaultImage else {
            fatalError("Nu exista link de imagine")
        }
        
        if let url = URL(string: image){
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    self.profileImage.image = UIImage(data: imageData)
                }
            }.resume()
        }
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor(named: "PlantHouse White")?.cgColor
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        sciNameLabel.adjustsFontSizeToFitWidth = true
        sciNameLabel.minimumScaleFactor = 0.2
        
        
        navigationItem.title = searchResult?.commonName.capitalized
        
    }
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
    }
    
    
    

    
}

extension SearchProfileViewController: PlantApiManagerDelegate{

    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
    func didUpdatePlantAPI(_ apiManager: APIManager, plant: PlantModel) {
        
        DispatchQueue.main.async { [self] in
            
            let stringToSplit = plant.description.components(separatedBy: ".")
            bio.text = stringToSplit[0] + "."
            if (stringToSplit[0].count < 90) {
                bio.text = stringToSplit[0] + "." + stringToSplit[1] + "."
            }
            
            waterLabel.text?.append(plant.watering)
            
            for lights in plant.sunlight {
                sunlightLabel.text?.append("\(lights.capitalized), ")
            }
            sunlightLabel.text?.removeLast(2)
            
            if plant.careLevel != "Unknown"{
                careLevelLabel.text?.append(plant.careLevel.capitalized)
            }else{
                careLevelLabel.isHidden = true
            }
            
            if plant.growthRate != "Unknown"{
                growthRateLabel.text?.append(plant.growthRate.capitalized)
            }else{
                growthRateLabel.isHidden = true
            }
            
            poisonLabel.text?.append(plant.poisonsPets)
        
            
            activityIndicator.stopAnimating()
            maskView.isHidden = true
            savePlantDetailsTemp(plant: plant)
            
        }
    }
    
    func savePlantDetailsTemp(plant: PlantModel){
        
        water = plant.watering.capitalized
        for lights in plant.sunlight {
            sunlight.append("\(lights.capitalized), ")
        }
        sunlight.removeLast(2)
        careLevel = plant.careLevel.capitalized
        growthRate = plant.growthRate.capitalized
        poisonsPets = plant.poisonsPets
        
    }
    
}

