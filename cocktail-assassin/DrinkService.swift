//
//  DrinkService.swift
//  cocktail-assassin
//
//  Created by Sambya Aryasa on 10/2/15.
//  Copyright (c) 2015 tw. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import CoreData

class DrinkService: NSObject {
    
    class func maximumDrinkAmount() -> Int {
        return 260
    }
    
    // Recipe = "P1-30/P2-15/V3-150"
    class func makeDrink(recipe recipe: String) -> Promise<Double> {
        let url = Constants.baseUrl.prod + "/make_drink/" + recipe
        
        return Promise<Double> { fulfill, reject in
            Alamofire.request(.POST, url)
                .responseJSON { (response) in
                    switch response.result {
                        case .Success(let value):
                            let statusCode = response.response?.statusCode ?? 500
                            if statusCode == 200 {
                                let stringValue = (value as! NSDictionary)["ready_in"] as! NSString
                                let readyIn = stringValue.doubleValue / 1000
                                fulfill(readyIn)
                            } else {
                                let statusError = NSError(domain: "DrinkService", code: statusCode, userInfo: nil)
                                reject(statusError)
                            }
                        case .Failure(let error):
                            reject(error)
                    }
            }
            // Dev
//            fulfill(5.0)
        }
        
    }
    class func initIngredients(managedContext: NSManagedObjectContext) {
        Ingredient.newIngredient(.DarkRum,   pumpNumber: 1, amountLeft: 100, ingredientClass: .Alcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.LightRum,  pumpNumber: 2, amountLeft: 100, ingredientClass: .Alcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.Vodka,     pumpNumber: 3, amountLeft: 100, ingredientClass: .Alcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.Gin,       pumpNumber: 4, amountLeft: 100, ingredientClass: .Alcoholic,managedContext: managedContext)
        Ingredient.newIngredient(.Tequila,   pumpNumber: 5, amountLeft: 50, ingredientClass: .Alcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.TripleSec, pumpNumber: 6, amountLeft: 50, ingredientClass: .Alcoholic,managedContext: managedContext)
      
        Ingredient.newIngredient(.Coke,           pumpNumber: 7, amountLeft: 400, ingredientClass: .NonAlcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.Lemonade,       pumpNumber: 8, amountLeft: 500, ingredientClass: .NonAlcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.OrangeJuice,    pumpNumber: 9, amountLeft: 400, ingredientClass: .NonAlcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.CranberryJuice, pumpNumber: 10, amountLeft: 500, ingredientClass: .NonAlcoholic, managedContext: managedContext)
        Ingredient.newIngredient(.LimeJuice,      pumpNumber: 11, amountLeft: 500, ingredientClass: .NonAlcoholic, managedContext: managedContext)
    }
    
    class func initComponents(managedContext: NSManagedObjectContext) {
        Component.newComponent(.Valve, id: "V1", name: "Valve 1", managedContext: managedContext)
        Component.newComponent(.Valve, id: "V2", name: "Valve 2", managedContext: managedContext)
        Component.newComponent(.Valve, id: "V3", name: "Valve 3", managedContext: managedContext)
        Component.newComponent(.Valve, id: "V4", name: "Valve 4", managedContext: managedContext)
        
        Component.newComponent(.Pump, id: "P1", name: "Pump 1", managedContext: managedContext)
        Component.newComponent(.Pump, id: "P2", name: "Pump 2", managedContext: managedContext)
        Component.newComponent(.Pump, id: "P3", name: "Pump 3", managedContext: managedContext)
        Component.newComponent(.Pump, id: "P4", name: "Pump 4", managedContext: managedContext)
        Component.newComponent(.Pump, id: "P5", name: "Pump 5", managedContext: managedContext)
        Component.newComponent(.Pump, id: "P6", name: "Pump 6", managedContext: managedContext)
    }
    
    class func createDrinkWithIngredient(name:String, imageName:String, ingredients: [IngredientType: NSNumber], editable: Bool, coreDataStack: CoreDataStack) -> Drink {
        let drink = Drink.newDrink(name, imageName: imageName, editable: editable, managedContext: coreDataStack.context)
        
        for (ingredientType, amountNeeded) in ingredients{
            drink.addIngredient(Ingredient.getIngredient(ingredientType, managedContext: coreDataStack.context)!, amount: amountNeeded)
        }
        
        coreDataStack.save()
        return drink
    }
    
    class func initDatabase(coreDataStack: CoreDataStack) {
        DrinkService.initComponents(coreDataStack.context)
        DrinkService.initIngredients(coreDataStack.context)

        DrinkService.createDrinkWithIngredient("Long Island Ice Tea",
            imageName: "long-island-iced-tea",
            ingredients: [.Vodka: 15, .LightRum: 15, .Tequila: 15, .TripleSec: 15, .Gin: 15, .Coke: 90],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Alpine Lemonade",
            imageName: "alpine-lemonade",
            ingredients: [.Vodka: 30, .Gin: 30, .LightRum: 30, .Lemonade: 60, .CranberryJuice: 60],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("The Ollie",
            imageName: "the-ollie",
            ingredients: [.Vodka: 60, .LightRum: 30, .Tequila: 30, .Lemonade: 150],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Cosmopolitan Classic",
            imageName: "cosmopolitan",
            ingredients: [.Vodka: 15, .TripleSec: 15, .CranberryJuice: 30, .LimeJuice: 15],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Margarita",
            imageName: "margarita",
            ingredients: [.Tequila: 30, .TripleSec: 30, .LimeJuice: 15],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Vodka Cranberry",
            imageName: "vodka-cranberry",
            ingredients: [.Vodka: 30, .CranberryJuice: 120, .LimeJuice: 15, .OrangeJuice: 30],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Black Widow",
            imageName: "black-widow",
            ingredients: [.Vodka: 30, .CranberryJuice: 30, .Lemonade: 30],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Rum and Coke",
            imageName: "rum-and-coke",
            ingredients: [.LightRum: 30, .Coke: 150],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Mix Your Own!!",
            imageName: "mix-your-own",
            ingredients: [.LightRum: 0, .Vodka: 0, .Gin: 0, .Tequila: 0, .TripleSec: 0, .Coke: 0, .Lemonade: 0, .OrangeJuice: 0, .CranberryJuice: 0],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Hula-Hula",
            imageName: "hula-hula",
            ingredients: [.Gin: 60, .OrangeJuice: 30, .TripleSec: 7.5 ],
            editable: false,
            coreDataStack: coreDataStack)
        
        DrinkService.createDrinkWithIngredient("Kamikaze",
            imageName: "kamikaze",
            ingredients: [.Vodka: 15, .TripleSec: 7.5],
            editable: false,
            coreDataStack: coreDataStack)
    }
}
