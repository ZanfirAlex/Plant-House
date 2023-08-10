//
//  ViewController.swift
//  PlantHouse
//
//  Created by Alexandru Zanfir on 23.06.2023.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeAnimation()
  
    }


    func typeAnimation() {
        
        titleLabel.text = ""
        var charIndex = 0.0
        let titleTitle = "PlantHouse"
        for letter in titleTitle{
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
    }
    
}

