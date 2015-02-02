//
//  DrinksViewController.swift
//  cocktail-assassin
//
//  Created by Sambya Aryasa on 21/1/15.
//  Copyright (c) 2015 tw. All rights reserved.
//

import UIKit
import QuartzCore

class DrinksViewController: UIViewController, iCarouselDataSource, iCarouselDelegate, ViewControllerDismissDelegate {
    private var carousel = iCarousel()
    private var pageControl = UIPageControl()
    private var transitionDrinkView = UIImageView()
    
    private var items = [
        Drink(name : "Angry Cocoa", image : "cocktail-4"),
        Drink(name : "Apricot Lemon Boot", image : "cocktail-5"),
        Drink(name : "Arctic Shake", image : "cocktail-1"),
        Drink(name : "Doomed Mix", image : "cocktail-2"),
        Drink(name : "Famous Desert Ocean", image : "cocktail-3"),
        Drink(name : "Gambler's Murder", image : "cocktail-4"),
        Drink(name : "Indefinite Desert Buster", image : "cocktail-5"),
        Drink(name : "Insane Stout Martini", image : "cocktail-1"),
        Drink(name : "Kiwi Blueberry", image : "cocktail-2"),
        Drink(name : "Nasty Coconut", image : "cocktail-3"),
        Drink(name : "Negative Drunken Mountain", image : "cocktail-4"),
        Drink(name : "Peppermint Mint Chaos", image : "cocktail-5"),
        Drink(name : "Pleasant Green", image : "cocktail-1"),
        Drink(name : "Plum Abyss", image : "cocktail-2"),
        Drink(name : "Random Royal Deep", image : "cocktail-3"),
        Drink(name : "Rocky Pretender", image : "cocktail-4"),
        Drink(name : "Sour Ecstacy", image : "cocktail-5"),
        Drink(name : "Ultimate Ochre Dirt", image : "cocktail-1"),
        Drink(name : "Unholy Schnapps Twister", image : "cocktail-2"),
        Drink(name : "Vanilla Punch", image : "cocktail-3")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()

        carousel.frame = view.frame
        carousel.type = .Custom
        carousel.dataSource = self
        carousel.delegate = self
        carousel.centerItemWhenSelected = false
        view.addSubview(carousel)
        
        pageControl.numberOfPages = items.count
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.4)

        pageControl.frame = {
            let viewHeight : CGFloat = 20,
                bottomPadding : CGFloat = 20,
                originY : CGFloat = self.view.frame.height - viewHeight - bottomPadding;
            return CGRectMake(0, originY, self.view.frame.size.width, viewHeight)
        }()
        
        carousel.addSubview(pageControl)
        
        carousel.currentItemIndex = items.count / 2
        carouselCurrentItemIndexDidChange(carousel)
        
        transitionDrinkView.contentMode = .ScaleAspectFit
        transitionDrinkView.hidden = true
        view.addSubview(transitionDrinkView)
    }
    
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
        return items.count
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!){
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    func onViewControllerDismiss(){
        UIView.transitionWithView(self.transitionDrinkView,
            duration: 0.3,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.transitionDrinkView.frame = Constants.drinkFrames.basicFrame
            }, completion: { finished in
                self.carousel.reloadData()
                
                UIView.transitionWithView(self.view,
                    duration: 0.2,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {
                        self.carousel.alpha = 1
                    }, completion:  { finished in
                        self.transitionDrinkView.hidden = true
                        
                })
        
        })
        
    }
    
    func carousel(_carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        var offset = _carousel.offsetForItemAtIndex(index)
        transitionDrinkView.frame = Constants.drinkFrames.basicFrame
        transitionDrinkView.scaleFrame(DrinkCarouselTransformation.getScale(offset))
        transitionDrinkView.setOriginX((view.frame.width/2) + DrinkCarouselTransformation.getXOffset(offset, carouselItemWidth: _carousel.itemWidth) - transitionDrinkView.frame.width/2)
        transitionDrinkView.setOriginY((view.frame.height - transitionDrinkView.frame.height)/2)
        
        transitionDrinkView.image = UIImage(named: items[index].image)
        
        transitionDrinkView.hidden = false
        (carousel.itemViewAtIndex(index) as UIImageView).image = nil
        
        UIView.transitionWithView(self.view,
            duration: 0.2,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: {
                self.carousel.alpha = 0
            }, completion: { finished in
                UIView.transitionWithView(self.transitionDrinkView,
                    duration: 0.3,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {
                        self.transitionDrinkView.frame = Constants.drinkFrames.expandedFrame
                    }, completion: { finished in
                        self.carousel.currentItemIndex = index
                        var drinkDetailsVC = DrinkDetailsViewController(drink: self.items[index])
                        drinkDetailsVC.dismissDelegate = self
                        self.presentViewController(drinkDetailsVC, animated: false, completion: {
                                                    })
                })
        })
        
        
    }
    
    
    func carousel(carousel: iCarousel!, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        var scale : CGFloat = DrinkCarouselTransformation.getScale(offset)
        var xOffset : CGFloat = DrinkCarouselTransformation.getXOffset(offset, carouselItemWidth: carousel.itemWidth)
        return
            CATransform3DScale(
                CATransform3DTranslate(transform, xOffset, 0, 0),
                scale,
                scale,
                1
            )
    }

    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .Wrap:
            return 1
        case .ShowBackfaces:
            return 0    
        default:
            return value
        }
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView! {
        if (view == nil) {
            view = DrinkView(frame: Constants.drinkFrames.basicFrame)
        }
        
        (view as DrinkView).setDrink(items[index])
        return view
    }
}
