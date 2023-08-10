//
//  SearchTableViewController.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 23.06.2023.
//

import Foundation
import UIKit
import CoreML
import Vision

class SearchTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [ResultsModel]()
    
    let imagePicker = UIImagePickerController()
    
    var apiManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "ReuseSearchCell")
        
        tableView.rowHeight = 120
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
       
        apiManager.delegate = self
        
  
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReuseSearchCell", for: indexPath) as! SearchCell
        
        cell.searchNameLabel.text = searchResults[indexPath.row].commonName.capitalized
        cell.searchSciNameLabel.text = searchResults[indexPath.row].scientificName.capitalized
        
        if let url = URL(string: searchResults[indexPath.row].defaultImage){
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                   cell.searchImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        
        cell.searchImageView.layer.cornerRadius = cell.searchImageView.frame.size.width / 2
        cell.searchImageView.layer.borderWidth = 2.0
        cell.searchImageView.layer.borderColor = UIColor(named: "PlantHouse White")?.cgColor
        cell.searchNameLabel.adjustsFontSizeToFitWidth = true
        cell.searchNameLabel.minimumScaleFactor = 0.2
        cell.searchSciNameLabel.adjustsFontSizeToFitWidth = true
        cell.searchSciNameLabel.minimumScaleFactor = 0.2


        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "SearchToProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SearchProfileViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.searchResult = searchResults[indexPath.row]
        }
    }
    
}


extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        DispatchQueue.main.async {
        
            if let plantName = searchBar.text {
                
                self.apiManager.fetchPlant(plantName: plantName, id: nil)

            }
        }
    }
    
}


extension SearchTableViewController: APIManagerDelegate{
    
    func didFailWithError(error: Error) {
        print(error)

    }
    
    
    func didUpdateAPI(_ apiManager: APIManager, result: [ResultsModel]) {
        DispatchQueue.main.async {
            
            self.searchResults = result
            self.tableView.reloadData()
            self.searchBar.endEditing(true)
        }
    }
    
    
    func nothingFound() {
        
        let alert = UIAlertController(title: "No Plants Found", message: "Might check your spelling or we do not yet have it in our database.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}


extension SearchTableViewController: UIImagePickerControllerDelegate {
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Choose Image Source", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            
            DispatchQueue.main.async { [self] in
                
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true)
                
            }
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            
            DispatchQueue.main.async { [self] in
                
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true)
                
            }
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            guard let ciimage = CIImage(image: userImage) else {
                fatalError("could not convert")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true)
    }
    
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: PlantRecognizer3_5_1().model) else {
            fatalError("Plant Image Recognition failed ")
        }
        
        let request = VNCoreMLRequest(model: model){ (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            print(results)
            
            if let firstResult = results.first{
                print(firstResult.identifier)
                DispatchQueue.main.async {
                    
                    self.apiManager.fetchPlant(plantName: firstResult.identifier, id: nil)
                    
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
            
        }catch {
            print(error)
        }
        
    }
    
    
    
}

