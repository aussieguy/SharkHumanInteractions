//
//  FetchLatLongViewController.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 6/2/21.
//
//Problem: When the program first starts and there is no data in the database, it will read the sharkAttacks.csv file and create records for each line item.  The problem is that when it comes to lat/long we need to look up this data using geoCoder.  Apple's geoCoder can't be hit with over 6,400 records each requiring a look up for their lat/long.  After awhile geoCoder will time out and stop sending back lat/long data.
//Solution: The solution to the problem is to break the data import into two steps.
//  Step one is to read the sharkAttacks.csv file and create records for each line item AND DON'T look up the lat/long.
//  Step two is to run a separate program that takes each record from newly created database and then looks up the lat/long for it.  THERE IS A TIMER so for each record there is a 5 second pause.  This will prevent geoCoder from timing out.  Then a flat file is created that only has the uniqID and the lat/long details.

// Subsequently when the program is run the first time by the user, it will import the sharkAttacks.csv file and create a database for this.  It will then read the flat file and then take each line entry and update the corresponding record in the database with the lat/long data.  UniqID is used to look up.  We do it this way as it takes many hours to look up lat/long information via geoCoder and we can't have the user experiencing this delay.  We could write the lat/long information to the sharkAttacks.csv file as this would make importing into the database easier.  However, this file is just a download from the original source website and we want to leave it as original as possible.




import UIKit
import CoreData

class FetchLatLongViewController: UIViewController {
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Connect up the database
    var items:[People]?
    var workingData = [People]()
    
    var recordCounter = 0
    
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var address:UITextField!
    @IBOutlet weak var showLatLong:UITextField!
    
    @IBAction func fetchNextRecord(_ Sender:Any) {
        
        //Fetch the next record.
        let nextRecord = workingData[recordCounter]
        recordCounter += 1
                
//Set up variables which are used to then look up the lat/long
        let nRLocation = nextRecord.location
        let nRArea = nextRecord.area
        let nRCountry = nextRecord.country
        
        
//What we are doing here is asking FileManager for a list of URL’s for the documents directory in the home directory. This returns an array of which the first entry will contain the documents directory. This will return a URL object for the documents directory.
// First create file by    touch filename //When all records have been written to this file, import it into the app.
        
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = URL(fileURLWithPath: "LatAndLong",relativeTo: directoryURL).appendingPathExtension("txt")
        
        //To find where LatAndLong.txt is located, uncomment the following line.
        //        print(directoryURL!)
        
        //Display screen information for this record.
        self.name.text = nextRecord.name
        self.address.text = nRLocation! + ", " + nRArea! + ", " + nRCountry!
        
        let incidentLocation = address.text!        //Fetch latitude and longitude for this record.
        let geoCoder = CLGeocoder()
  
//Try and look up lat/long for this record.
        geoCoder.geocodeAddressString(incidentLocation) { (placemarks, error) in
            
            let placemarks = placemarks
            let coords = placemarks?.first?.location

            if coords != nil {
                nextRecord.latitudelongitude = "\(coords!)"                 //Successful look up.
            } else {
                nextRecord.latitudelongitude = "Unable to determine"        //Set as default value.
            }
            
//Show incident latitude and longitude on screen.
            self.showLatLong.text = nextRecord.latitudelongitude!

//Read LatAndLong.text file and append data to it.
            do {
                let savedData = try String(contentsOf: fileURL)
                
//Append new string to current string on file
                let stringToWrite = String(nextRecord.uniqID) + " " + nextRecord.latitudelongitude!
                let newStringToWrite = savedData + "\n" + stringToWrite       
                
//Write to file
                try newStringToWrite.write(to: fileURL, atomically: true, encoding: .utf8)
                
            } catch {
                print(error.localizedDescription)
            }
        }   //geoCoder
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch all the data
        do {
            try items = context.fetch(People.fetchRequest())
        } catch  {
            
        }
        
        workingData = items!
    }
    
}
//// Strip out only latitude and longitude data.
////        <+25.79220520,-80.13515960> +/- 100.00m (speed -1.00 mps / course -1.00) @ 1/10/21, 10:35:07 AM Australian Eastern Daylight Time
//
//func cleanUpLatitudeLongitude(location: String) -> String {
//    var newLocation = ""
//    var commaPosition = 0
//    var tempLoc = location
//    var latitude = ""
//    var longitude = ""
//
//    tempLoc.removeFirst()   //Remove leading < sign
//
//    //  We are wanting to extract     +25.79220520,
//    for character in tempLoc {
//        if character != "," {
//            latitude.append(character)
//            commaPosition += 1
//        }
//        if character == "," {
//            break
//        }
//    }
//
//    // We are wanting to extract     -80.13515960>
//    var loopCounter = 0
//    for character in tempLoc {
//        if loopCounter > commaPosition {
//            if character == ">" {
//                break
//            }
//            longitude.append(character)
//        }
//        loopCounter += 1
//    }
//
//    newLocation = latitude + "," + longitude
//
//    return newLocation
//}


