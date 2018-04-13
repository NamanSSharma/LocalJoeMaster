import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewJoeProfileController: UIViewController {
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    @IBOutlet weak var image9: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backAction(_ sender: Any) {
        // self.performSegue(withIdentifier: "backToMaps", sender: self)
        
        
        /* let appDelegate = UIApplication.shared.delegate as? AppDelegate
         let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let homeController =  mainStoryboard.instantiateViewController(withIdentifier: "ExploreController") as! ExploreController
         appDelegate?.window?.rootViewController = homeController
         
         let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: "TabbarIdentifier")
         // let targetNavigationController = UINavigationController(rootViewController: tabBarViewController!)
         self.show(tabBarViewController!, sender: nil) */
        
    }
    
    @IBOutlet weak var joeName: UILabel!
    @IBOutlet weak var joeProfession: UILabel!
    @IBOutlet weak var joeRating: UILabel!
    
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    let storage = Storage.storage().reference();
    let userID : String = (Auth.auth().currentUser?.uid)!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .done, target: self, action: #selector(backAction) )
        
        ref = Database.database().reference()
        
        loadImages();
        
        //Tap Image to Enlarge
        let image1Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image1.isUserInteractionEnabled = true;
        image1.addGestureRecognizer(image1Tap);
        
        let image2Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image2.isUserInteractionEnabled = true;
        image2.addGestureRecognizer(image2Tap);
        
        let image3Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image3.isUserInteractionEnabled = true;
        image3.addGestureRecognizer(image3Tap);
        
        let image4Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image4.isUserInteractionEnabled = true;
        image4.addGestureRecognizer(image4Tap);
        
        let image5Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image5.isUserInteractionEnabled = true;
        image5.addGestureRecognizer(image5Tap);
        
        let image6Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image6.isUserInteractionEnabled = true;
        image6.addGestureRecognizer(image6Tap);
        
        let image7Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image7.isUserInteractionEnabled = true;
        image7.addGestureRecognizer(image7Tap);
        
        let image8Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image8.isUserInteractionEnabled = true;
        image8.addGestureRecognizer(image8Tap);
        
        let image9Tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        image9.isUserInteractionEnabled = true;
        image9.addGestureRecognizer(image9Tap);
    }
    
    
    
    func loadImages(){
        //Load Name
        ref = Database.database().reference()
        let userID : String = (Auth.auth().currentUser?.uid)!
        let usersRef = self.ref.child("users").child(userID);
        // let usersStorageRef = self.storage.child("users").child(userID);
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            // Get user's name
            let joeID = value?["checkedOut"] as? String ?? ""
            let joeRef = self.ref.child("users").child(joeID);
            let joeStorageRef = self.storage.child("users").child(joeID);
            joeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                // Get user's name
                let joeName = value?["name"] as? String ?? ""
                let joeProfession = value?["joeType"] as? String ?? ""
                self.joeName.text = joeName;
                self.joeProfession.text = joeProfession;
                //rating, description
            }) { (error) in
                print(error.localizedDescription)
            }
            let image1Stored = joeStorageRef.child("img0")
            let image2Stored = joeStorageRef.child("img1")
            let image3Stored = joeStorageRef.child("img2")
            let image4Stored = joeStorageRef.child("img3")
            let image5Stored = joeStorageRef.child("img4")
            let image6Stored = joeStorageRef.child("img5")
            let image7Stored = joeStorageRef.child("img6")
            let image8Stored = joeStorageRef.child("img7")
            let image9Stored = joeStorageRef.child("img8")
            
            image1Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image1.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image2Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image2.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image3Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image3.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image4Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image4.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image5Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image5.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image6Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image6.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image7Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image7.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image8Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image8.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
            image9Stored.getData(maxSize: 1*1000*1000){ (data,error) in
                if error == nil{
                    self.image9.image = UIImage(data:data!)
                }else{
                    print(error?.localizedDescription ?? "")
                }
            }
        })
        
        
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        //newImageView.contentMode = .scaleAspectFit
        newImageView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
}
