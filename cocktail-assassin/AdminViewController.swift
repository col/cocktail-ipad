//
//  AdminViewController.swift
//  cocktail-assassin
//
//  Created by Colin Harris on 21/10/15.
//  Copyright © 2015 tw. All rights reserved.
//

import Foundation
import UIKit

class AdminViewController: UIViewController {
    
    var coreDataStack: CoreDataStack!
    
    @IBAction func mappingCLicked() {
        let controller = IngredientMappingViewController(coreDataStack: coreDataStack)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func cleaningClicked() {
//        let controller = CleaningViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("CleaningViewController") as! CleaningViewController
        controller.coreDataStack = coreDataStack
        navigationController?.pushViewController(controller, animated: true)
    }
    
}