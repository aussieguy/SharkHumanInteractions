//
//  LaunchViewController.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 18/3/21.
//
//To do: Create a read.me file that explains the logic of the program.



import UIKit

//Reference to managed object context.  Used for all core data work.
public let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class ViewController: UIViewController {

    @IBOutlet weak var lastRecordButton: UIButton!
    @IBOutlet weak var lastRecordButton2: UIButton!
    @IBOutlet weak var appDescLabel: UILabel!
    
    @IBAction func buttonPressed (sender: UIButton) {
        performSegue(withIdentifier: "showLastRecordDetails", sender: nil)
    }
    @IBAction func buttonPressed2 (sender: UIButton) {
        performSegue(withIdentifier: "showLastRecordDetails", sender: nil)
    }
    @IBAction func sharkButton (sender: UIButton) {
        performSegue(withIdentifier: "showMainView", sender: nil)
    }
    @IBAction func sharkButton2 (sender: UILabel) {
        performSegue(withIdentifier: "showMainView", sender: nil)
    }
//Display settings
    @IBAction func settingsButton (Sender:Any) {
         performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    let shapeLayer = CAShapeLayer()
    var items:[People]? //Data to be retrieved
    let dispatchGroup = DispatchGroup()
    let firstRecord = UserDefaults.standard         //Display the newest record on the splash screen.
    var labelTextDate = ""
    var labelTextName = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Try and fetch some records.
        do {
            try items = context.fetch(People.fetchRequest())            

//If there are no records then don't show splash screen and just transition to MainViewController
            if items?.count != 0 {
                
                labelTextDate = firstRecord.string(forKey: "date")!
                labelTextName = firstRecord.string(forKey: "name")!
                
                lastRecordButton.setTitle(labelTextDate, for: .normal)
                lastRecordButton.showsTouchWhenHighlighted = true
                lastRecordButton.contentHorizontalAlignment = .left     //Left align
                
                lastRecordButton2.setTitle(labelTextName, for: .normal)
                lastRecordButton2.showsTouchWhenHighlighted = true
                lastRecordButton2.contentHorizontalAlignment = .left

            } else {

                drawProgressIndicator() //Display animation

                dispatchGroup.enter()
                DispatchQueue.main.async {
                    
                    readSharkDataFile()         //Located in ImportData.swift
                    
                    self.dispatchGroup.wait()   //Waits for previous to finish.
                    
                    //We need the navController to be displayed for the app so turn it back on.
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.navigationBar.barTintColor = .none

                    self.performSegue(withIdentifier: "showMainView", sender: nil)
                }
                dispatchGroup.leave()
                
            }
        } catch  {
        }
    }

    func drawProgressIndicator() {

        let trackLayer = CAShapeLayer()
        let center = view.center
        
        //Draw track layer for circle to follow
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: 50,
                                        startAngle: -CGFloat.pi/2,
                                        endAngle: 2*CGFloat.pi,
                                        clockwise: true)
        
        trackLayer.path = circularPath.cgPath      //The path to take
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10           //Thickness of line.
        trackLayer.fillColor = UIColor.clear.cgColor   //Center of circle.
        
        //Add the track layer to the view
        view.layer.addSublayer(trackLayer)
        
        //Draw circle layer for animation
        shapeLayer.path = circularPath.cgPath               //The path to take
        shapeLayer.lineCap = .round                         //Edge of circle being drawn
        shapeLayer.strokeColor = UIColor.blue.cgColor       //Circle Color
        shapeLayer.fillColor = UIColor.clear.cgColor        //Center of circle.
        shapeLayer.lineWidth = 10                           //Thickness of line.
        shapeLayer.strokeEnd = 0                            //Where to stop stroking the path.
        
        //Add the circle to the view
        view.layer.addSublayer(shapeLayer)
        
        //Set up animation parameters
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 17        //How long to take to draw circle
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        //Begin animation of circle
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Display the person's details
        let detailsDestination = segue.destination as? DetailsTableViewController
        
        detailsDestination?.uniqID = Int64(firstRecord.integer(forKey: "uniqID"))
        
    }

    
}
