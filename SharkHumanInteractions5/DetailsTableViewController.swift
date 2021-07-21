//
//  DetailsTableViewController.swift
//  SharkHumanInteractions
//
//  Created by Glen Hobby on 02/02/20.
//

import UIKit
import CoreData
import MapKit

class DetailsTableViewController: UITableViewController {
    
    let personFields = 14              //Number of fields in each record.  This determines number of rows in the tableView.
    var personDetails = [String]()
    var cellHeadings = ["Name : ","Gender : ","Age : ","Country : ","State :  ","Location : ","Year : ","Date : ","Time : ","Fatal : ","Injury : ","Shark species : ","Activity : ","Latitude/Longitude : "]
    var newLocation = ""
    var uniqID = Int64()
    
    //Reference to managed object context
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[People]?         //Connect the database
    var workingData = [People]()

    @IBOutlet weak var topMapButton: UIButton!
    @IBAction func topMapButton (_ Sender:Any) {
        
        //Only segue to mapping if there is latitude and longitude data on file for this incident.
        if workingData[0].latitudelongitude! != "Unable to determine" {
            performSegue(withIdentifier: "showMap", sender: nil)
        } else {
            
            UpDatePersonRecord(alertTitle: "Unable to display map",
                               alertMessage: "There are no latitude and longitude coordinates for this incident.  Try changing the location information to the nearest town or suburb.",
                               placeHolder: workingData[0].location!,
                               cellDetailsTappedNumber: 5)
        }
    }

    @IBAction func mapButton (_ Sender:Any) {

        //Only segue to mapping if there is latitude and longitude data on file for this incident.
        if workingData[0].latitudelongitude! != "Unable to determine" {
            performSegue(withIdentifier: "showMap", sender: nil)
        } else {
            
            UpDatePersonRecord(alertTitle: "Unable to display map",
                               alertMessage: "There are no latitude and longitude coordinates for this incident.  Try changing the location information to the nearest town or suburb.",
                               placeHolder: workingData[0].location!,
                               cellDetailsTappedNumber: 5)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topMapButton.setTitleColor(.white, for: .normal)
        topMapButton.setTitle("Locate on map", for: .normal)

//Set up a background image for the tableView
        let backgroundImage = "Shark.jpg"
        let image = UIImage(named: backgroundImage)
        let imageView = UIImageView(image: image)
                
        tableView.backgroundView = imageView
        tableView.backgroundView?.alpha = 0.3

//Retrieve the person so we can display their details.
        let fetchRequest = People.fetchRequest() as NSFetchRequest
//Convert Int64 to string as NSPredicate works on strings.
        fetchRequest.predicate = NSPredicate(format: "uniqID == %@", "\(uniqID)" )
        
        do {
            try items = context.fetch(fetchRequest)
        } catch  {
            print("Error")
        }
        
        workingData = items!
        
        //Try and look up lat/long data using just area and country.
        if workingData[0].latitudelongitude == "Unable to determine" {

            let lessAccurateIncidentLocation = workingData[0].area! + ", " + workingData[0].country!
            let leastAccurateIncidentLocation = workingData[0].country!

            let geoCoder = CLGeocoder()

            geoCoder.geocodeAddressString(lessAccurateIncidentLocation) { (placemarks, error) in
                let placemarks = placemarks
                let coords = placemarks?.first?.location
                
                if coords != nil {
                    
                    self.workingData[0].latitudelongitude = "\(coords!)" + " F"     //Add a flag to indicate this is not an accurate location
                    do {
                        try context.save()
                        
                    } catch  {
                    }
                } else {

                    geoCoder.geocodeAddressString(leastAccurateIncidentLocation) { (placemarks, error) in
                        let placemarks = placemarks
                        let coords = placemarks?.first?.location

                        if coords != nil {
                            self.workingData[0].latitudelongitude = "\(coords!)" + " F"     //Add a flag to indicate this is not accurate.
                            do {
                                try context.save()
                            } catch {
                            }
                        }
                    }   //Second geoCoder closure
                }
            }   //First geoCoder closure
        }
        personDetails =  [workingData[0].name!,workingData[0].gender!,workingData[0].age!,workingData[0].country!,workingData[0].area!,workingData[0].location!,workingData[0].year!,workingData[0].date!,workingData[0].time!,workingData[0].fatal!,workingData[0].injury!,workingData[0].species!,workingData[0].activity!,workingData[0].latitudelongitude!]
        
//If shark species is not provied then display something.
        switch workingData[0].species {
        case "  "," ","":
            personDetails[11] = "Information not available"
        default:
            print()
        }
    }
    
    //Configure number of sections.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Configure number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personFields
    }
    
    //Configure cell data.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath)
        cell.textLabel?.text = cellHeadings[indexPath.row]
        cell.detailTextLabel?.text = personDetails[indexPath.row]
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Don't allow for editing of Lat/Long coords.
        if indexPath.row != 13 {
            
            let cellContents = personDetails[indexPath.row]
            let cellDetailsTappedNumber = indexPath.row
            var myTitle = cellHeadings[indexPath.row]
            myTitle.removeLast()        //Remove trailing ": "
            myTitle.removeLast()
            
            UpDatePersonRecord(alertTitle: myTitle,
                               alertMessage: "Enter new details and tap Save",
                               placeHolder: cellContents,
                               cellDetailsTappedNumber:cellDetailsTappedNumber)
        }
    }
    
    //When user taps on a cell, display an alert so user can edit data, then save this new data.
    func UpDatePersonRecord(alertTitle:String,
                            alertMessage:String,
                            placeHolder:String,
                            cellDetailsTappedNumber:Int) {
        
        //Retrieve all records.
        do {
            try items = context.fetch(People.fetchRequest())
        } catch {
        }
        
        //Set up alert title and message to be displayed.
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        //Create the alert
        alert.addTextField()
        
        //Add the text to be displayed in the alert
        let textField = alert.textFields![0]
        textField.text = placeHolder
        
        //Add cancel button to the alert
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        //Add save button and configure its actions.
        let saveButton = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: { [weak self] _ in
                                        
                                        if let newText = alert.textFields?.first?.text {
                                            
                                            self?.personDetails[cellDetailsTappedNumber] = newText
                                            
                                            let wDArea = (self?.workingData[0].area!)!
                                            let wDCountry = (self?.workingData[0].country!)!
                                            let wDLocation = (self?.workingData[0].location!)!
                                            
                                            //Look up new lat/long coords if any of country, area or location have changed.
                                            switch cellDetailsTappedNumber {
                                            
                                            case 3,4,5:
                                                //Location field was changed.
                                                if cellDetailsTappedNumber == 5 {
                                                    self?.newLocation = newText + " " + wDArea + " " + wDCountry
                                                    }
                                                
                                                //Area field was changed.
                                                if cellDetailsTappedNumber == 4 {
                                                    self?.newLocation = wDLocation + " (" + newText + " " + wDCountry
                                                }
                                                
                                                //Country field was changed.
                                                if cellDetailsTappedNumber == 3 {
                                                    self?.newLocation = wDLocation + " " + wDArea + " " + newText
                                                }
                                                
                                                //Fetch latitude and longitude.
                                                let geoCoder = CLGeocoder()
                                                geoCoder.geocodeAddressString(self!.newLocation) { (placemarks, error) in
                                                    
                                                    let placemarks = placemarks
                                                    let coords = placemarks?.first?.location
                                                    
                                                    if coords != nil {
                                                        self?.workingData[0].latitudelongitude = "\(coords!)"
                                                    } else {
                                                        self?.workingData[0].latitudelongitude = "Unable to determine"
                                                    }
                                                    //Save latitude and longitude.
                                                    do {
                                                        try context.save()
                                                    } catch {
                                                    }
                                                }
                                                
                                            default:
                                                print()
                                            }       //Case statement
                                            
                                            switch cellDetailsTappedNumber {
                                            case 0:
                                                self?.workingData[0].name = newText
                                            case 1:
                                                self?.workingData[0].gender = newText
                                            case 2:
                                                self?.workingData[0].age = newText
                                            case 3:
                                                self?.workingData[0].country = newText
                                            case 4:
                                                self?.workingData[0].area = newText
                                            case 5:
                                                self?.workingData[0].location = newText
                                            case 6:
                                                self?.workingData[0].year = newText
                                            case 7:
                                                self?.workingData[0].date = newText
                                            case 8:
                                                self?.workingData[0].time = newText
                                            case 9:
                                                switch newText {
                                                case "no","No","NO","yes","Yes","YEs","YeS","YES":            //Don't save any other input style.
                                                    self?.workingData[0].fatal = newText
                                                default:
                                                    print()                 //Do nothing
                                                }                                            
                                            case 10:
                                                self?.workingData[0].injury = newText
                                            case 11:
                                                self?.workingData[0].species = newText
                                            case 12:
                                                self?.workingData[0].activity = newText
                                                
                                            default:
                                                print()         //Do nothing
                                            }   //Cast statement.
                                            
                                            //Save the changes made.
                                            do {
                                                try context.save()
                                            } catch {
                                            }
                                        }
                                        self!.tableView.reloadData()        //We've made changes so redisplay the tableView
                                       })          //Closure for Save button.
        
        //Add buttons to the alert
        alert.addAction(cancelButton)
        alert.addAction(saveButton)
        
        //Display the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//Return to main view
        let tableDestination = segue.destination as? MainViewController
        
        tableDestination?.name = workingData[0].name!
        tableDestination?.country = workingData[0].country!
        tableDestination?.area = workingData[0].area!
        tableDestination?.year = workingData[0].year!
        
//Display on map
        let mapDestination = segue.destination as? MapViewController

        personDetails =  [workingData[0].name!,workingData[0].gender!,workingData[0].age!,workingData[0].country!,workingData[0].area!,workingData[0].location!,workingData[0].year!,workingData[0].date!,workingData[0].time!,workingData[0].fatal!,workingData[0].injury!,workingData[0].species!,workingData[0].activity!,workingData[0].latitudelongitude!]

        mapDestination?.individualDetails = personDetails
        mapDestination?.numberOfRecords = 1         //There would only ever be one record as we are displaying information on just one record in the displaytableVC
    }
    

}
