//
//  StripePaymentVC.swift
//  joeDemo
//
//  Copyright © 2018 User. All rights reserved.
//

import UIKit
import Stripe

class StripePaymentVC: UIViewController , STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var payButton: UIButton!
    var paymentTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        // add stripe built-in text field to fill card information in the middle of the view
        super.viewDidLoad()
        let frame1 = CGRect(x: 20, y: 70, width: self.view.frame.size.width - 40, height: 40)
        paymentTextField = STPPaymentCardTextField(frame: frame1)
        paymentTextField.center = view.center
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        //disable payButton if there is no card information
        payButton.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CardIOUtilities.preload()
    }
    
    
    @IBAction func payButtonClicked(_ sender: Any) {
        
        let card = paymentTextField.cardParams
        
        getStripeToken(card: card)
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func getStripeToken(card:STPCardParams) {
        
        
        // get stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                
                
                self.postStripeToken(token: token)
            
            } else {
                
                
                print("Something is wrong. Please try again!")
                
            }
        }
    }
    
    // charge money from backend
    func postStripeToken(token: STPToken) {
        
        //Set up these params as your backend require
     
        //TODO: Send params to your backend to process payment
        
        print("Success Token: \(token)")
        
        let alert = UIAlertController.init(title: "Success", message: "You have successfully transferred the amount", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel) { (action:UIAlertAction!) in
            
            self.dismiss(animated: true, completion: nil)
            
        })
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid {
            payButton.isEnabled = true
        }
    }
    
    //MARK: - CardIO Methods
    
    //Allow user to cancel card scanning
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        print("user canceled")
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    //Callback when card is scanned correctly
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
            
            //dismiss scanning controller
            paymentViewController?.dismiss(animated: true, completion: nil)
            
            //create Stripe card
            let card: STPCardParams = STPCardParams()
            card.number = info.cardNumber
            card.expMonth = info.expiryMonth
            card.expYear = info.expiryYear
            card.cvc = info.cvv
            
            //Send to Stripe
            getStripeToken(card: card)
            
        }
    }
    
}
