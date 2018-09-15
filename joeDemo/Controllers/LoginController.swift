import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginController: UIViewController {
    
    var ref: DatabaseReference!
    let reachability = Reachability()!
    
    @IBOutlet weak var segmentControl: UISegmentedControl! //login/signup
    @IBOutlet weak var name: UITextField! //name for signup
    @IBOutlet weak var user: UITextField! //email
    @IBOutlet weak var pass: UITextField! //password
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var actionButton: UIButton! //submit email/pass
    @IBOutlet weak var forgotPass: UIButton! //forgot password button
    
   
    @IBAction func segmentClick(_ sender: Any) { //choosing between login/signup
        if segmentControl.selectedSegmentIndex == 0 //Login Option
        {   name.isHidden = true; //don't need name for login
            phone.isHidden = true; //don't need phone for login
        }else{
        name.isHidden = false; // need name for signup
        phone.isHidden = false; //need phone for signup
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) { //click enter
        if user.text != "" && pass.text != ""//do the following if email/pass is entered
        {
            if segmentControl.selectedSegmentIndex == 0 //Login User
            {   Auth.auth().signIn(withEmail: user.text!, password: pass.text!, completion: { (user, error) in //backend verification
                    if user != nil //if the user exists
                    {   print("SUCCESS")
                        self.performSegue(withIdentifier: "loginSegue", sender: self) //proceed to the homescreen
                    }
                    else { //if the user does not exist
                        let alert = UIAlertController(title: "Invalid Login", message: "Sorry, the Email/Password do not match our records", preferredStyle: UIAlertControllerStyle.alert)
                        // alert actions (buttons)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        if let myError = error?.localizedDescription
                        { print(myError)
                        }
                        else{
                           print("ERROR")
                        }
                    }
                })
            }
            else //User is choosing to create an account
            {
                PhoneAuthProvider.provider().verifyPhoneNumber(phone.text!, uiDelegate: nil) { (verificationID, error) in
                    if let error = error {
                       //error
                        print (error)
                        return
                    }
                    
                    let alertController = UIAlertController(title: "Verification", message: "Please enter the verification code sent to your phone number:", preferredStyle: .alert)
                    
                    let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                        if let verificationCodeUser:String = alertController.textFields?[0].text {
                            //check verification
                            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                            let credential = PhoneAuthProvider.provider().credential(
                                withVerificationID: verificationID!,
                                verificationCode: verificationCodeUser)
                            
                            Auth.auth().createUser (withEmail: self.user.text!, password: self.pass.text!, completion: { (newUser, error) in
                                if newUser != nil
                                {   //Successful
                                    print("SUCCESS")
                                    let values = ["name": self.name.text!, "email": self.user.text!, "joeType": "none", "numPhotos": "0"] //set new user values
                                    let userID : String = (Auth.auth().currentUser?.uid)!
                                    let usersRef = self.ref.child("users").child(userID);
                                    usersRef.updateChildValues(values, withCompletionBlock: {(err,ref) in //put the values into database
                                        if err != nil{
                                            print(err as Any)
                                            return
                                        }
                                        print("Saved user successfully into Firebase DB")
                                    })
                                    
                                    /* Auth.auth().signIn (with: credential) { (user, error) in
                                        if let error = error {
                                            print(error)
                                            
                                            let user = Auth.auth().currentUser;
                                            user?.delete();
                                            return
                                        }else{
                                            // User is signed in
                                            self.performSegue(withIdentifier: "loginSegue", sender: self) //proceed to the homescreen
                                        }
                                        
                                    } */
                                    
                                }
                                else //signing up failed
                                {
                                    // create the alert
                                    let alert = UIAlertController(title: "Invalid Sign Up", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                                    // add the actions (buttons)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    // show the alert
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    if let myError = error?.localizedDescription
                                    {
                                        print(myError)
                                    }
                                    else
                                    {
                                        print("ERROR")
                                    }
                                }
                            })
                            
                           
                            
                        } else {
                            // user did not fill field
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
                    
                    alertController.addTextField { (textField) in
                        textField.placeholder = "Email"
                    }
                    
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                   
                }
                
                
            }
        }
    }
    
    
    @IBAction func forgotAction(_ sender: Any) { //user has forgotten their password
        
       // Auth.auth().sendPasswordReset(withEmail: user.text!) { (error) in
       //self.performSegue (withIdentifier: "forgotPassSegue", sender: self)
        
       
        let alertController = UIAlertController(title: "Forgot Password", message: "Please input your email:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                Auth.auth().sendPasswordReset(withEmail: field.text!) { (error) in}
                
                let alert = UIAlertController(title: "Thanks!", message: "Check your email to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        ref = Database.database().reference()
        
        Auth.auth().addStateDidChangeListener { auth, user in //login user automatically if they signed in previously
            if let user = user {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            } else {
                // No user is signed in.
            }
        }
        
        if segmentControl.selectedSegmentIndex == 0 //Login User
        {   name.isHidden = true;
            phone.isHidden = true;
        }
       
        reachability.whenUnreachable = { _ in //alert for no internet connection
            DispatchQueue.main.async {
                // create the alert
                let alert = UIAlertController(title: "No Internet Connection", message: "Sorry, this app will not work without any internet connection", preferredStyle: UIAlertControllerStyle.alert)
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        
        //no internet connection start
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async{
                // create the alert
                let alert = UIAlertController(title: "No Internet", message: "Sorry, the app can't function without the internet.", preferredStyle: UIAlertControllerStyle.alert)
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
            
        }catch{
            print("could not start notifier")
        }
    }
    @objc func internetChanged(note: Notification){
        let reachability = note.object as! Reachability
        if reachability.isReachable {
        }else{
            let alert = UIAlertController(title: "No Internet", message: "Sorry, the app can't function without the internet.", preferredStyle: UIAlertControllerStyle.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    //no internet connection end
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        name.resignFirstResponder()
        user.resignFirstResponder()
        pass.resignFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

