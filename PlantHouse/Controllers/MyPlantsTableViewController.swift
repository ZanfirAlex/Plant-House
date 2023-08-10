//
//  MyPlantsTableViewController.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 24.06.2023.
//

import Foundation
import UIKit
import CoreData

class MyPlantsTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var myPlantList = [Plant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MyPlantsCell", bundle: nil), forCellReuseIdentifier: "ReuseMyPlantsCell")
        
        tableView.rowHeight = 220
        
        loadItems()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPlantList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseMyPlantsCell", for: indexPath) as! MyPlantsCell
        
        let plant = myPlantList[indexPath.row]
        
        if plant.nickname != "Nickname" && plant.nickname != nil && plant.nickname != "nickname"{
            cell.plantNameLabel.text = plant.nickname
        }else{
            cell.plantNameLabel.text = plant.name?.capitalized
        }
        cell.plantSciNameLabel.text = plant.sciName?.capitalized
        cell.waterCellLabel.text = "💧: \(plant.watering ?? "Unkown")"
        let stringToSplit = plant.sun?.components(separatedBy: "/")
        let stringToSplit2 = stringToSplit?[0].components(separatedBy: ",")
        cell.sunCellLabel.text = "☀️: \(stringToSplit2?[0].capitalized  ?? "Unknown")"
        
        if let imageData = plant.image{
            cell.imageCellView.image = UIImage(data: imageData)
        }
        
        cell.sunCellLabel.adjustsFontSizeToFitWidth = true
        cell.waterCellLabel.adjustsFontSizeToFitWidth = true


        
        return cell
        
        
    }
    
    func loadItems() {
        
        let request : NSFetchRequest<Plant> = Plant.fetchRequest()
        
        do {
            myPlantList = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "MyPlantsToProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MyPlantsProfileViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedPlant = myPlantList[indexPath.row]
        }
    }
    
}
