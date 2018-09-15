//
//  ViewController.swift
//  AnimatedPageView
//
//  Created by Alex K. on 12/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

var sharedSecrets = "3985e07136ba47a8b8a8a4f4be6fc5c0"

enum RegisteredPurchase : String {
    case becomeJoe = "becomeJoe"
}

class NetworkActivityIndicatorManager : NSObject{
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        loadingCount += 1
    }
    class func NetworkOperationFinished(){
        if loadingCount > 0{
            loadingCount -= 1
        }
        if loadingCount == 0{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
        }
        
    }
}

class paper: UIViewController {
    
    @IBOutlet var skipButton: UIButton!
    
    let bundleID = "com.naman.localJoe"
    var becomeJoe = RegisteredPurchase.becomeJoe
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: Asset.wallet.image,
                           title: "Become A Joe",
                           description: "List your services on this app, and appear on our search page. Clients will be able to find YOU when they are looking for a service.",
                           pageIcon: Asset.key.image,
                           color: UIColor(red:0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: Asset.banks.image,
                           title: "Monthly Subscription",
                           description: "By becoming a Joe, you will be enrolled into a monthly payment plan of $15. Don't worry though, you will have a complimentary month to try it out first! ",
                           pageIcon: Asset.wallet.image,
                           color: UIColor(red: 0.40, green: 0.69, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: Asset.stores.image,
                           title: "Watch the Results",
                           description: "Sit back as clients in your area find you and request for your service! ",
                           pageIcon: Asset.shoppingCart.image,
                           color: UIColor(red: 0.61, green: 0.56, blue: 0.74, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.tabBar.isHidden = true
        skipButton.isHidden = true
        
        setupPaperOnboardingView()
        
        view.bringSubview(toFront: skipButton)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // Add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
}

// MARK: Actions

extension paper {
    
    @IBAction func skipButtonTapped(_: UIButton) {
        self.performSegue(withIdentifier: "applicationSegue", sender: self)
        
    }
    
    func getInfo(purchase : RegisteredPurchase){
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue], completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()

        })
    }
    
    func purchase(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
        })
    }
    
    func restorePurchases(){
        //https://www.youtube.com/watch?v=dwPFtwDJ7tc&t=383s @ 25 mins
    }
}

// MARK: PaperOnboardingDelegate

extension paper: PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        skipButton.isHidden = index == 2 ? false : true
    }
    
    func onboardingDidTransitonToIndex(_: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        //item.titleLabel?.backgroundColor = .redColor()
        //item.descriptionLabel?.backgroundColor = .redColor()
        //item.imageView = ...
    }
}

// MARK: PaperOnboardingDataSource

extension paper: PaperOnboardingDataSource {
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    //    func onboardinPageItemRadius() -> CGFloat {
    //        return 2
    //    }
    //
    //    func onboardingPageItemSelectedRadius() -> CGFloat {
    //        return 10
    //    }
    //    func onboardingPageItemColor(at index: Int) -> UIColor {
    //        return [UIColor.white, UIColor.red, UIColor.green][index]
    //    }
}


//MARK: Constants
extension paper {
    
    private static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    private static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
}


