//
//  DrinkIngredientCell.swift
//  cocktail-assassin
//
//  Created by Colin Harris on 3/3/15.
//  Copyright (c) 2015 tw. All rights reserved.
//

import UIKit

protocol RemoveIngredientDelegate {
    func removeDrinkIngredient(ingredient: DrinkIngredient)
}

class DrinkIngredientCell: UITableViewCell {

    var slider = UISlider()
    var ingredientNamelabel = UILabel()
    var ingredientAmountLabel = UILabel()
    var removeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
    var drinkIngredient: DrinkIngredient?
    var delegate: RemoveIngredientDelegate?
    var editMode = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        addSubview(slider)
        addSubview(ingredientNamelabel)
        addSubview(ingredientAmountLabel)
        addSubview(removeButton)

        slider.frame = CGRectMake(255, 25, 250, 20)
        slider.addTarget(self, action: "sliderChanged", forControlEvents: .ValueChanged)
        
        ingredientNamelabel.frame = CGRectMake(0, 25, 160, 20)
        ingredientNamelabel.textAlignment = .Right
        ingredientNamelabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        
        ingredientAmountLabel.frame = CGRectMake(160, 25, 75, 20)
        ingredientAmountLabel.textAlignment = .Right
        ingredientAmountLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)

        removeButton.hidden = !editMode
        removeButton.frame = CGRectMake(15, 25, 20, 20)
        removeButton.layer.cornerRadius = 0.5 * removeButton.bounds.size.width
        removeButton.setTitle("-", forState: .Normal)
        removeButton.backgroundColor = UIColor.redColor()
        removeButton.addTarget(self, action: "removeClicked", forControlEvents: .TouchUpInside)
        removeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 16)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func removeClicked() {
        delegate?.removeDrinkIngredient(drinkIngredient!)
    }

    func sliderChanged() {
        drinkIngredient?.amount = (Int)(slider.value*200)
        ingredientAmountLabel.text = "\(drinkIngredient!.amount)ml"
    }
    
    func displayDrinkIngredient(drinkIngredient: DrinkIngredient) {
        self.drinkIngredient = drinkIngredient
        slider.setValue(drinkIngredient.amount.floatValue / 200, animated: false)
        ingredientNamelabel.text = drinkIngredient.ingredient.type
        ingredientAmountLabel.text = "\(self.drinkIngredient!.amount)ml"
        removeButton.hidden = !editMode
    }
    
}
