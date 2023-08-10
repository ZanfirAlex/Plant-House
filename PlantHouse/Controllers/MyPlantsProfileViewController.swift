//
//  MyPlantsProfileViewController.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 24.06.2023.
//

import Foundation
import UIKit

class MyPlantsProfileViewController: UIViewController{
    
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var poisonousToPetsLabel: UILabel!
    @IBOutlet weak var growthRateLabel: UILabel!
    @IBOutlet weak var careLeveLabel: UILabel!
    @IBOutlet weak var sunlightLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var bioText: UILabel!
    @IBOutlet weak var sciNameLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedPlant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPlantDetails()
        
    }
    
    func loadPlantDetails(){
        
        nameLabel.text = selectedPlant?.name
        sciNameLabel.text = selectedPlant?.sciName
        nicknameLabel.text = selectedPlant?.nickname
        bioText.text = selectedPlant?.bio
        
        if let water = selectedPlant?.watering, water != "Unknown" {
            waterLabel.text = "💧 Water: \(water)"
        }else{
            waterLabel.isHidden = true
        }
        
        if let sun = selectedPlant?.sun, sun != "Unknown" {
            sunlightLabel.text = "☀️ Sunlight: \(sun)"
        }else{
            sunlightLabel.isHidden = true
        }
        
        if let care = selectedPlant?.careLevel, care != "Unknown" {
            careLeveLabel.text = "🪴 Care Level: \(care)"
        }else{
            careLeveLabel.isHidden = true
        }
        
        if let growth = selectedPlant?.growthRate, growth != "Unknown" {
            growthRateLabel.text = "🌱 Growth Rate: \(growth)"
        }else{
            growthRateLabel.isHidden = true
        }
        
        poisonousToPetsLabel.text = "🐾 Poisonous to Pets: \(selectedPlant?.poison ?? "Yes")"  

        
        if let imageData = selectedPlant?.image{
            plantImage.image = UIImage(data: imageData)
        }
        
        plantImage.layer.cornerRadius = plantImage.frame.size.width / 2
        plantImage.layer.borderWidth = 2.0
        plantImage.layer.borderColor = UIColor(named: "PlantHouse White")?.cgColor
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.2
        sciNameLabel.adjustsFontSizeToFitWidth = true
        sciNameLabel.minimumScaleFactor = 0.2
        
        
        if selectedPlant?.nickname == "Nickname" || selectedPlant?.nickname == nil || selectedPlant?.nickname == "nickname" {
            navigationItem.title = selectedPlant?.name
        } else {
            navigationItem.title = selectedPlant?.nickname
        }
        
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "You can always add it back from Search.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            DispatchQueue.main.async {
                
                guard let plant = self.selectedPlant else {
                    fatalError("Planta actuala nu exista")
                }
                
                self.context.delete(plant)
                
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Change Plant's Nickname", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            
            if textField.text != nil && textField.text != self.selectedPlant?.nickname {
                if textField.text!.count <= 16 && textField.text != "" {
                    self.selectedPlant?.nickname = textField.text
                    self.nicknameLabel.text = self.selectedPlant?.nickname
                    self.saveItems()
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Nickname (1-16 Characters)"
            textField = alertTextField
            
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        
        do {
            try context.save()
            loadPlantDetails()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
}
