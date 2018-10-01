//
//  MessagesViewController.swift
//  joeDemo
//
//  Created by Yudhvir Raj on 2018-04-21.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import JSQMessagesViewController

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseMessaging
import SCLAlertView
import PopupDialog


struct UserObj {
    let id   : String
    let name : String
}

struct FirebaseJSQMessage {
    let id   : String
    let date : String
    let msg  : JSQMessage
}

class MessagesViewController : JSQMessagesViewController {
    
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    let userID : String = (Auth.auth ().currentUser?.uid)!

    
    var chatId : String = ""
    var quotesRef: DatabaseReference!;
    var displayID: String = ""
    var joeDescription: String = ""
    var icon : UIImage!
    var count: Int = 1

    
    /* var currentUser : UserObj {
        return user1
    } */
    
    var currentUser      : UserObj = UserObj (id : "", name : "")
    var conversationUser : UserObj = UserObj (id : "", name : "")
    
    var newChat : Bool = false
    
    // All the messages of user1, user2
    var messages = [FirebaseJSQMessage]()
}

extension MessagesViewController {
    
    func addNoNavControllerButtons () {
        let navbar = UINavigationBar(frame: CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 75))
        
        navbar.tintColor = UIColor.lightGray
        self.view.addSubview (navbar)
        
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.backgroundColor = UIColor.red
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
        self.navigationItem.titleView = button
        
       // let navItem = UINavigationItem (title: self.conversationUser.name)
        let navBarbutton = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: goBack, action: nil)
        
        //navItem.leftBarButtonItem = navBarbutton
        
        //navbar.items = [navItem]
    }
    
    @objc func clickOnButton(button: UIButton) {
        
    }
    
    @objc func firstButton() {
        print("First button tapped")
    }
    
    func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    func addViewOnTop () {
        //self.navigationItem.title = self.conversationUser.name
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //button.backgroundColor = UIColor.red
        button.setTitle("\(self.conversationUser.name)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(self.clickOnButton), for: .touchUpInside)
        self.navigationItem.titleView = button
        
        let barButton = UIButton.init(type: .custom)
        //set image for button
        barButton.setImage(UIImage(named: "info.png"), for: .normal)
        //add function for button
        barButton.addTarget(self, action: #selector(infoButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        barButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34 )
        barButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        barButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        let rightButton = UIBarButtonItem(customView: barButton)
        
        let secondbarButton = UIButton.init(type: .custom)
        //set image for button
        secondbarButton.setImage(UIImage(named: "star.png"), for: .normal)
        //add function for button
        secondbarButton.addTarget(self, action: #selector(ratingButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        secondbarButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34 )
        secondbarButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        secondbarButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        let secondrightButton = UIBarButtonItem(customView: secondbarButton)
        
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItems = [rightButton,secondrightButton]
        
        /* let selectableView = UIView (frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        selectableView.backgroundColor = .red
        let randomViewLabel  = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 16))
        randomViewLabel.text = self.conversationUser.name
        selectableView.addSubview (randomViewLabel)
        view.addSubview (selectableView) */
    }
    
    //This method will call when you press button.
    @objc func infoButtonPressed() {
        let usersStorageRef = self.storage.child("users").child(self.displayID);
        let profile = usersStorageRef.child("profilePic")
        profile.getData(maxSize: 1*1000*1000){ (data,error) in
            if error == nil{
                self.icon = UIImage(data:data!)!
                //self.icon = self.maskRoundedImage(image: UIImage(data:data!)!, radius: 50)
                self.icon = self.icon!.circleMasked
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                    kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                    kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                    showCloseButton: false,
                    dynamicAnimatorActive: false,
                    buttonsLayout: .horizontal
                )
                let alert = SCLAlertView(appearance: appearance)
                _ = alert.addButton("Close", target:self, selector:#selector(self.firstButton))
                
                // let icon = UIImage(named:"custom_icon.png")
                let color = UIColor.blue
                
                
                
                _ = alert.showCustom("Description", subTitle: self.joeDescription, color: color, closeButtonTitle: "close", circleIconImage: self.icon!)
            }else{
                print(error?.localizedDescription ?? "")
                self.icon = UIImage(named:"profilePic")!
                
            }
        }
    }
    
    @objc func ratingButtonPressed(animated: Bool = true) {
        
        // Create a custom view controller
        let ratingVC = RatingViewController(nibName: "RatingViewController", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "CANCEL", height: 60) {
            //self.label.text = "You canceled the rating dialog"
        }
        
        // Create second button
        let buttonTwo = DefaultButton(title: "RATE", height: 60) {
           // self.label.text = "You rated \(ratingVC.cosmosStarRating.rating) stars"
            
            let joeIDRef = self.ref.child (FirebaseDatabaseRefs.chats).child (self.chatId)
            self.quotesRef = self.ref.child (FirebaseDatabaseRefs.quotes);
            
            
            joeIDRef.observeSingleEvent (of: .value, with:
                {
                    (snapshot) in
                    let value = snapshot.value as! NSDictionary
                    let firstID: String = value["firstID"] as! String
                    let secondID: String = value["secondID"] as! String
                    if (self.userID == firstID){
                        self.displayID = secondID;
                        let joeDescriptionRef = self.ref.child("users/").child(self.displayID)
                        joeDescriptionRef.observeSingleEvent(of: .value, with:
                            {
                                (snapshot) in
                                if let val = snapshot.value as? NSDictionary{
                                    if let joeRating = val["joeRating"] as? String {
                                        print(joeRating)
                                        if let numberOfRatings = val["numberofRatings"] as? String {
                                            print(numberOfRatings)
                                            let rating:Float? = Float(joeRating)
                                            let numRating:Float? = Float(numberOfRatings)
                                            let customerRating:Float? = (Float(ratingVC.cosmosStarRating.rating) / 5.0)
                                            let newRating:Float? = ((rating! * numRating!) + customerRating!)/(numRating! + 1)
                                            let updateRating = "\(newRating!)"
                                            let updateNumber = "\(numRating! + 1)"
                                            //store information in database
                                            let values = [
                                                "joeRating" : updateRating,
                                                "numberofRatings": updateNumber,
                                                ]
                                            
                                            joeDescriptionRef.updateChildValues(values, withCompletionBlock: {
                                                (err,ref) in
                                                if err != nil {
                                                    print (err as Any)
                                                    return
                                                }
                                                print("Saved user successfully into Firebase DB")
                                                
                                            }
                                            )
                                        }
                                    }
                                }
                        }
                        )
                        
                    }else {
                        self.displayID = firstID
                        let joeDescriptionRef = self.ref.child(self.displayID)
                        joeDescriptionRef.observeSingleEvent(of: .value, with:
                            {
                                (snapshot) in
                                if let val = snapshot.value as? NSDictionary{
                                    if let joeRating = val["joeRating"] as? String {
                                        print(joeRating)
                                        if let numberOfRatings = val["numberofRatings"] as? String {
                                            print(numberOfRatings)
                                            let rating:Float? = Float(joeRating)
                                            let numRating:Float? = Float(numberOfRatings)
                                            let customerRating:Float? = (Float(ratingVC.cosmosStarRating.rating) / 5.0)
                                            let newRating:Float? = ((rating! * numRating!) + customerRating!)/(numRating! + 1)
                                            let updateRating = "\(newRating!)"
                                            let updateNumber = "\(numRating! + 1)"
                                            //store information in database
                                            let values = [
                                                "joeRating" : updateRating,
                                                "numberofRatings": updateNumber,
                                                ]
                                            
                                            joeDescriptionRef.updateChildValues(values, withCompletionBlock: {
                                                (err,ref) in
                                                if err != nil {
                                                    print (err as Any)
                                                    return
                                                }
                                                print("Saved user successfully into Firebase DB")
                                                
                                            }
                                            )
                                        }
                                    }
                                }
                        }
                        )
                    }
            }
            )
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        present(popup, animated: animated, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad ()
        
        self.edgesForExtendedLayout = []
        
        ref = Database.database().reference ()
        
        self.senderId          = currentUser.id
        self.senderDisplayName = currentUser.name
        
        self.addViewOnTop ()
        
        if self.newChat {
            addNoNavControllerButtons ()
        }
        
        let chatRef = ref.child (FirebaseDatabaseRefs.chats).child (chatId).child ("messages")
        let joeIDRef = ref.child (FirebaseDatabaseRefs.chats).child (chatId)
        quotesRef = ref.child (FirebaseDatabaseRefs.quotes);
        
        let leftButton = UIButton ()
        let sendImage = #imageLiteral(resourceName: "pin.png")
        leftButton.setImage (sendImage, for: [])

        self.inputToolbar.contentView.leftBarButtonItem = leftButton;
        
        joeIDRef.observeSingleEvent (of: .value, with:
            {
                (snapshot) in
                let value = snapshot.value as! NSDictionary
                let firstID: String = value["firstID"] as! String
                let secondID: String = value["secondID"] as! String
                if (self.userID == firstID) {
                    self.displayID = secondID;
                    let joeDescriptionRef = self.ref.child("users/").child(self.displayID)
                    joeDescriptionRef.observeSingleEvent(of: .value, with:
                        {
                            (snapshot) in
                            if let val = snapshot.value as? NSDictionary{
                                if let description = val["joeDescription"] as? String {
                                    self.joeDescription = description
                                    if let joeRating = val["joeRating"] as? String {
                                        print(joeRating)
                                        var rating:Float? = Float(joeRating)
                                        rating = rating! * 5;
                                        let ratingDouble:Double? = Double(rating!)
                                        if (ratingDouble! >= 0 && ratingDouble! <= 1.5) {self.joeDescription += "\n\n Rating: " + "\u{2606} star"}
                                        if (ratingDouble! > 1.5 && ratingDouble! <= 2.5) {self.joeDescription += "\n\n Rating: " + "\u{2606} \u{2606} stars"}
                                        if (ratingDouble! > 2.5 && ratingDouble! <= 3.5) {self.joeDescription += "\n\n Rating: " + "\u{2606} \u{2606} \u{2606} stars"}
                                        if (ratingDouble! > 3.5 && ratingDouble! <= 4.5) {self.joeDescription += "\n\n Rating: " + "\u{2606} \u{2606} \u{2606} \u{2606}  stars"}
                                        if (ratingDouble! > 4.5 && ratingDouble! <= 5.0) {self.joeDescription += "\n\n Rating: " + "\u{2606} \u{2606} \u{2606} \u{2606} \u{2606}  stars"}
                                    // self.joeDescription += "\n\n Rating: \(ratingDouble!.truncate(places: 2))/5 Stars" + "\u{2606}"
                                    }
                                }
                            }
                        }
                    )
                    
                } else {
                    self.displayID = firstID
                    let joeDescriptionRef = self.ref.child(self.displayID)
                    joeDescriptionRef.observeSingleEvent(of: .value, with:
                        {
                            (snapshot) in
                            if let val = snapshot.value as? NSDictionary{
                                if let description = val["joeDescription"] as? String {
                                    self.joeDescription = description
                                    if let joeRating = val["joeRating"] as? String {
                                        print(joeRating)
                                        var rating:Float? = Float(joeRating)
                                        rating = rating! * 5;
                                        let ratingDouble:Double? = Double(rating!)
                                        self.joeDescription += "\n This Joe's Rating: \(ratingDouble!.truncate(places: 2))/5 Stars"
                                    }
                                }
                            }
                    }
                    )
                }
            }
        )
        

        
        chatRef.observe (.value) {
            (snapshot) in
            
                self.messages = []
            
                let _ = snapshot.key
                guard let value = snapshot.value as? NSDictionary else {
                    return
                }
            
                // Use external call to get date perhaps, such as server
                for (key, msg) in value {
                    print ("\(key) --> \(msg)")
                    print(type(of: msg))
                    guard let msgValues = msg as? [String: Any] else {
                        break
                    }
                    
                    let message:JSQMessage = JSQMessage (senderId: msgValues["senderId"] as? String, displayName: msgValues["displayName"] as? String, text: msgValues["text"] as? String)
                    
                    self.messages.append (FirebaseJSQMessage (id: key as! String, date: msgValues["date"]! as! String, msg: message))
                }

                self.messages.sort (by:
                    {
                        (lhs, rhs) -> Bool in
                            return lhs.date < rhs.date
                    }
                )
            
                self.collectionView.reloadData ()
        }
    }
    
    
    
}

extension MessagesViewController {
    // newChat button to go back
    @objc private func goBack () {
        // var messagesVC : MessagesViewController = storyboard.instantiateViewController (withIdentifier: "ChatView") as! MessagesViewController
        
        let storyboard :UIStoryboard = UIStoryboard.init (name: "Main", bundle: nil)
        let explore:ExploreController = storyboard.instantiateViewController (withIdentifier: "Base") as! ExploreController
        // let vc = UIStoryboard.init (name: "Main", bundle: nil).instantiateViewController (withIdentifier: "ChatView") as! UINavigationController
        // self.navigationController?.pushViewController(messagesVC, animated: true)
        
        UIApplication.topViewController()?.present (explore, animated: true, completion: nil)
        print ("PRESSED")
        
        // Last view controller
        // _ = navigationController?.popViewController (animated: true)
        
        // Root view controller
        // _ = navigationController?.popToRootViewController (animated: true)
    }
}

extension MessagesViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let messageId = UUID().uuidString
        let message   = JSQMessage (senderId: senderId, displayName: senderDisplayName, text: text)
        
        let fbMessage = FirebaseJSQMessage (id: messageId, date: String (date.timeIntervalSince1970), msg: message!)
        
        self.messages.append (fbMessage)
        
        let chatRef = ref.child (FirebaseDatabaseRefs.chats).child (self.chatId).child ("messages")
        let messageValues =
            [
                "senderId"    : senderId,
                "displayName" : senderDisplayName,
                "text"        : text,
                "date"        : String (date.timeIntervalSince1970),
                "senderUserID" : self.userID
            ]
        chatRef.child (messageId).updateChildValues (messageValues)
        
        finishSendingMessage ()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "estimatorSegue" {
            if let destination = segue.destination as? LocalJoeEstimator {
                destination.chatID = self.chatId
            }
        }
    }
    
    override func didPressAccessoryButton (_ sender: UIButton!) {
        print ("Button pressed")
        self.performSegue(withIdentifier: "estimatorSegue", sender: self)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message         = messages[indexPath.row]
        let messageUsername =  message.msg.senderDisplayName
        
        return NSAttributedString (string: messageUsername!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory =  JSQMessagesBubbleImageFactory ()
        
        let message       = messages[indexPath.row]
        
        print (currentUser.id + " " + message.msg.senderId)
        
        if currentUser.id == message.msg.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage (with: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1))
        }
        func collectionView(_ collectionView: JSQMessagesCollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
            
            cell.textView!.textColor = UIColor.black
            
            return cell
        }

        
        return bubbleFactory?.incomingMessagesBubbleImage (with: UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages [indexPath.row].msg
    }
}
extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
