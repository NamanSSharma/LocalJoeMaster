import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MessageUI

struct profileRow {
    let name: String
}

class ProfileViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    var rows = [profileRow]()
    let identifier: String = "tableCell"
    //database
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["Info@localjoeservices.com"])
        mailComposerVC.setSubject("Local Joe Support Ticket")
        mailComposerVC.setMessageBody("" , isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send support ticket", message: "Please try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated:true, completion:  nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated:true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        let usersStorageRef = self.storage.child("users").child(userID);
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            // Get user's name
            let myName = value?["name"] as? String ?? ""
            self.navigationItem.title = myName;
            let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.blue]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        }) { (error) in
            print(error.localizedDescription)
        }
        
        initializeTheRecipes()
    }
    
    func initializeTheRecipes() {
        self.rows = [profileRow(name: "Edit Account"),
                        //profileRow(name: "Notification Settings"),
                        profileRow(name: "Change Password"),
                        //profileRow(name: "Change Address"),
                        //profileRow(name: "Add Card"),
                        profileRow(name: "Become A Joe"),
                        profileRow(name: "Need Help"),
                        profileRow(name: "Invite a friend"),
                        profileRow(name: "Logout")]
        
        self.tableView.reloadData()
    }
    
    // MARK: UITableView DataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? TableCell {
            cell.configurateTheCell(rows[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0)
        { //Edit Account
           self.performSegue(withIdentifier: "editAccountSegue", sender: self)
        }
        
      /*  if(indexPath.row == 1)
        { //notification settings
            
        } */
        
        if(indexPath.row == 1)
        { //Change Password
            let alert = UIAlertController(title: "Change Password", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
                let user = Auth.auth().currentUser
                if let user = user {
                    Auth.auth().sendPasswordReset(withEmail: (user.email)!) { (error) in}
                    let alert = UIAlertController(title: "Success!", message: "Check your email to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
           
            
        }
        
        /*if(indexPath.row == 3)
        { //Change Address
            
        }
        
        if(indexPath.row == 4)
        { //Add Card
            
        }*/
        
        if(indexPath.row == 2)
        { //Become Joe
            self.performSegue(withIdentifier: "becomeJoeSegue", sender: self)
            
        }
        
        if(indexPath.row == 3)
        { //Need Help
            
            let mailComposeViewController = self.configureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            }else {
                self.showMailError()
            }        }
        
        if(indexPath.row == 4)
        { //Invite a friend            
            //Set the default sharing message.
            let message = "Hey there! Checkout LocalJoe for all your quick job needs."
            //Set the link to share.
            if let link = NSURL(string: "http://itunes.com/")
            {
                let objectsToShare = [message,link] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
                
            }
        }
        
        if(indexPath.row == 5)
        { //Logout
            do{
                try Auth.auth().signOut()
            }
            catch let error as NSError
            {
                print (error.localizedDescription)
            }
            self.performSegue(withIdentifier: "signoutSegue", sender: self)

        }
        
    }
   
}

