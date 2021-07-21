//
//  ViewController.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 26/1/21.
//

import UIKit
import CoreData
import DropDown         //CocoaPods drop down menu framework.
import AVFoundation     //Required to make sound after downloading new data.

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [" by year "," by name "," by country "," by state "," by location"]             //search menu

        return menu
    }()

    let searchBy = [" by year "," by name "," by country "," by state "," by location "]
    let searchBar = UISearchBar()
    var searchMenuOptionSelected = Int()
    let searchButton = UIButton()

    @IBOutlet weak var tableView: UITableView!
    
    //Create search button and action when it is tapped.
    @IBAction func searchButton(_ Sender: Any) {
        
        searchBar.isHidden = false
        tableView.alpha = 0.3           //Reduce background view of MainVC.

//Set up a frame so we can anchor the menu to it.
        let myView = UIView(frame: navigationController?.navigationBar.frame ?? .zero)
        navigationController?.navigationBar.topItem?.titleView = myView
        
        let topView = navigationController?.navigationBar.topItem?.titleView
        
//Set up drop down menu features
        menu.anchorView = topView
        menu.textFont = UIFont.systemFont(ofSize: 18)
        menu.animationduration = 1  //Duration of the menu.show or menu.hide animation
        menu.shadowColor = UIColor(white: 0.6, alpha: 1)
        menu.shadowOpacity = 0.9
        menu.shadowRadius = 25
        menu.textColor = UIColor(red: 0.12, green: 0.42, blue: 1, alpha: 1)
        menu.cornerRadius = 10
        menu.width = 163
        
//Display the menu
        menu.show()
            
//Respond to user selecting a menu item.
        menu.selectionAction = { index, title in            //Returns the index and title of the menu choice.
            
//Display searchBar only when user taps on Search button.
            self.searchBar.delegate = self               //Enable user interaction on searchBar.
            self.searchBar.searchTextField.textColor = .white   //Set text colour
            self.searchBar.backgroundColor = .black         //Makes it easier to see the searchBar
            
            self.searchBar.placeholder = title              //Display the menu choice in the searchBar.

//Set color of Cancel button
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor : UIColor.white], for: .normal)
            
            self.searchBar.showsCancelButton = true         //Display Cancel button
            
            self.navigationItem.titleView = self.searchBar  //Display the search bar
            
            self.tableView.alpha = 1.0                      //Restore the background view.
            self.searchMenuOptionSelected = index           //The selected menu option from the search menu.
 
            if index == 0 {                                 //Display a numeric keyboard if search by Year has been chosen
                self.searchBar.keyboardType = .numberPad
            } else {                                        //Otherwise display an ascii keyboard
                self.searchBar.keyboardType = .asciiCapable
            }
            
//Clear the searchBar of any previous searches
            self.searchBar.text = nil
            
        }
    }

//Create search button and action when it is tapped.
    @IBAction func mapButton(_ Sender: Any) {
        performSegue(withIdentifier: "showMap", sender: nil)        //Exit looping as we do have something to map.
    }

//Set up what to do when the Cancel button is tapped on SearchBar.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchMenuOptionSelected = 0      //By default records are shown in Year order.  Need to reset to this.
        searchBar.isHidden = true        //Cancel needs to remove the searchBar.
        searchBar.text = nil            //Clear searchBar
        fetchData()                     //Reload the data
        tableView.reloadData()          //Display the data again.
        
        navigationItem.prompt = "Number of shark attacks: \(workingData.count)"
        searchBar.resignFirstResponder()                                        //Dismiss keyboard.

    }

//Implement search.  UISearchBarDelegate triggers actioning this method.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.placeholder = searchBy[searchMenuOptionSelected]
        var currentRecord = 0
        textSearchedFor = searchText
        
//workingData contains the results of the search as we type in characters.  It is empty to begin with.
        workingData = []
        
        //When the user backspaces and deletes the search text, redisplay all data again.
        if searchText == "" {
            workingData = items!        //ie. display all the data again
        }

        switch searchMenuOptionSelected {
        
        //Search by year
        case 0:
            while currentRecord < items!.count {
                if items![currentRecord].year!.lowercased().contains(searchText.lowercased()) {
                    workingData.append(items![currentRecord])
                }
                currentRecord += 1
            }
            
        //Search by name
        case 1:
            while currentRecord < items!.count {
                
                if items![currentRecord].name!.lowercased().contains(searchText.lowercased()) {
                
                    workingData.append(items![currentRecord])
                }
                currentRecord += 1
            }

        //Search by country
        case 2:
            while currentRecord < items!.count {
                if items![currentRecord].country!.lowercased().contains(searchText.lowercased()) {
                    workingData.append(items![currentRecord])
                }
                currentRecord += 1
            }
            
        //Search by state
        case 3:
            while currentRecord < items!.count {
                if items![currentRecord].area!.lowercased().contains(searchText.lowercased()) {
                    workingData.append(items![currentRecord])
                }
                currentRecord += 1
            }
            
        //Search by location
        case 4:
            while currentRecord < items!.count {
                if items![currentRecord].location!.lowercased().contains(searchText.lowercased()) {
                    workingData.append(items![currentRecord])
                }
                currentRecord += 1
            }
            
        default:
            return
        }
        
        tableView.reloadData()      //Display the new data.
        navigationItem.prompt = "Number of shark attacks: \(workingData.count)"
                
    }

//                                    ================================================
    var refreshControl = UIRefreshControl()
    
    //Reference to managed object context
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var items:[People]?                 //Data for the table.   Connect up our database.
    var workingData = [People]()

    var cellTapped = [String]()
    var personRecordNumber = 0      //Record number in CoreData of person tapped on to display their details.
    var name = ""                   //Declare these so we can assign them from DetailsVC
    var country = ""
    var area = ""
    var location = ""
    var year = ""
    
    var textSearchedFor = ""        //The actual text enterred into the search box.
 
//                                  =====================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.prompt = ""          //Set up the prompt for displaying later.

        tableView.dataSource = self         //Set up data source.
        tableView.delegate = self       //Enable user interaction

        fetchData()    //By uniqId order.  There will be data to fetch as we get here from ViewController which checks this first.
//deleteAllData()
        
        //        navigationItem.prompt = "Number of shark attacks: \(items!.count)"
        navigationItem.prompt = "Number of shark attacks: \(workingData.count)"
        
        let navBarImage = UIImage(named: "fish.png")
        navigationController?.navigationBar.setBackgroundImage(navBarImage, for: .default)

        //Set up refresh features.
        tableView.refreshControl = refreshControl
        
//Set up a background image for the tableView
        let backgroundImage = "Shark.jpg"
        let image = UIImage(named: backgroundImage)
        let imageView = UIImageView(image: image)
        
        tableView.backgroundView = imageView
        tableView.backgroundView?.alpha = 0.3
        
        tableView.refreshControl?.tintColor = UIColor.blue      //Spinner and colour.
        tableView.refreshControl?.backgroundColor = .clear
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Checking for any new data ...",
                                                                       attributes: [NSAttributedString.Key.foregroundColor : UIColor.blue])
                                                                       
        refreshControl.addTarget(self,
                                 action: #selector(refreshData),
                                 for: .valueChanged)

    }

//Download new data and integrate it with our current records.
    @objc func refreshData() {

        var recordCounter = Int64(workingData.count)    //Set to current number in CoreData
        var personRecord:[People]?
        let fetchRequest = People.fetchRequest() as NSFetchRequest


        let doubleQuoteChar:Character = "\""
        var sharkArray = [String]()
        let firstRecord = UserDefaults.standard

//This file takes 24 hours to update on the server after you have uploaded it.
        let fileURL = URL(string: "https://thecolourblue.com.au/sharkAttacks.csv")!
        let task = URLSession.shared.downloadTask(with: fileURL) { localURL, urlResponse, error in
            
// localURL will be nil if no internet connection can be made.
            if localURL != nil {
                if let contentsReceived = try? String(contentsOf: localURL!) {

                    sharkArray = contentsReceived.components(separatedBy: "\n") //Newline separates each new record.

//If first line is   <!DOCTYPE html>   then we couldn't download file, ie. file not found - 404 error.
                    if sharkArray.first! != "<!DOCTYPE html>" {
                        sharkArray.removeFirst(1)       //Header information only - not required.
                        
//The array is in date order from most current to oldest.  We want to write this to the database from oldest to the most current.  So need to reverse array order.
                        sharkArray.reverse()            //Read from end to first.
                        
                        //Each array cell holds a string record.  Take each cell and turn it into an array.
                        for stringIncident in sharkArray {
                            if !stringIncident.isEmpty {      //At the end of our data are empty spreadsheet rows.  Don't process these.
                                
// Need to change text that looks like this:  quick, brown, "Fox, jumped, over",the         into         quick, brown, Fox jumped over,the,lazy
                                var arrayIncident = Array(stringIncident)
                                
                                //Now read each character of the array record checking if it is a double quote or comma.  Process if true.
                                var charCounter = 0
                                var firstDoubleQuote = false
                                var secondDoubleQuote = false
                                
                                for characterRead in arrayIncident {
                                    
                                    if characterRead == doubleQuoteChar {  //First time we've found a double quote.
                                        
                                        if !firstDoubleQuote && !secondDoubleQuote {
                                            firstDoubleQuote = true
                                            secondDoubleQuote = false
                                        } else {
                                            firstDoubleQuote = false
                                            secondDoubleQuote = true
                                        }
                                        
                                        if !firstDoubleQuote && secondDoubleQuote {
                                            firstDoubleQuote = false
                                            secondDoubleQuote = false
                                        }
                                    }
                                    
                                    if characterRead == "," && firstDoubleQuote && !secondDoubleQuote {
                                        arrayIncident[charCounter] = " "
                                    }
                                    
                                    charCounter += 1
                                }
                                
//We've now read fully through the record.  Build a new array containing each processed record.
                                let newString = String(arrayIncident)
                                
                                //Create an array from newString and split it on comma.
                                var newSharkArray = newString.components(separatedBy: ",")
                                
                                //Don't go any further if date field is blank.  No point in processing blank records.
                                if newSharkArray[0] != "" {

                                    switch newSharkArray[7] {
                                    case "male","Male","female","Female","":
                                        newSharkArray[7] = "Unknown"
                                    default:
                                        newSharkArray[7] = newSharkArray[7]
                                    }
                                    
//If person is not on file then save them to the database.  First try and look them up by name.  If name == unknown the look up by other means.
                                    if newSharkArray[7] == "Unknown" {
                                        
                                        fetchRequest.predicate = NSPredicate(format: "date == %@ AND country == %@ AND area == %@ AND location == %@", newSharkArray[0],newSharkArray[3],newSharkArray[4],newSharkArray[5])
                                        
                                    } else {
                                        
                                        fetchRequest.predicate = NSPredicate(format: "name == %@", newSharkArray[7])
                                        
                                    }

                                    do {
                                        try personRecord = context.fetch(fetchRequest)

                                        if personRecord!.count == 0 {
                                            
                                            let newPerson = People(context: context)    //Create a newPerson object
                                            
                                            newPerson.date = newSharkArray[0]
                                            newPerson.year = newSharkArray[1]
                                            newPerson.type = newSharkArray[2]
                                            newPerson.country = newSharkArray[3]
                                            newPerson.area = newSharkArray[4]
                                            newPerson.location = newSharkArray[5]
                                            newPerson.activity = newSharkArray[6]

                                            //We don't want gender in the name column
                                            switch newSharkArray[7] {
                                            case "male","Male","female","Female","":
                                                newPerson.name = "Unknown"
                                                
                                            default:
                                                newPerson.name = newSharkArray[7]
                                            }

                                            //Gender column.  Expand out abbreviation
                                            switch newSharkArray[8] {
                                            case "M":
                                                newPerson.gender = "Male"
                                            case "M ":
                                                newPerson.gender = "Male"
                                            case "F":
                                                newPerson.gender = "Female"
                                            case "F ":
                                                newPerson.gender = "Female"
                                                
                                            default:
                                                newPerson.gender = "Unknown"
                                            }
                                            
                                            newPerson.age = newSharkArray[9]
                                            newPerson.injury = newSharkArray[10]
                                            
//If it's a fatal attack then the injury is not described only listed as FATAL
                                            if newSharkArray[10].contains("FATAL") {
                                                newPerson.fatal = "Yes"
                                            } else {
                                                newPerson.fatal = "No"
                                            }
                                            
                                            newPerson.time = newSharkArray[11]
                                            newPerson.species = newSharkArray[12]
                                            newPerson.latitudelongitude = "Unable to determine"     //Set default value
                                            

                                            let accurateLocation = newSharkArray[5] + ", " + newSharkArray[4] + ", " + newSharkArray[3]
                                            let geoCoder = CLGeocoder()
                                            
        //Try and look up latitude longitude coords using location, area and country.
                                            geoCoder.geocodeAddressString(accurateLocation) { (placemarks, error) in
                                                let placemarks = placemarks
                                                let coords = placemarks?.first?.location
                                                
                                                if coords != nil {
                                                    newPerson.latitudelongitude = "\(coords!)"
                                                }
                                            }

                                            recordCounter += 1
                                            newPerson.uniqID = recordCounter
    
                                            //Set values for display on splash screen but also to segue from splash screen to DetailsTableVC
                                            firstRecord.setValue(newPerson.name!, forKey: "name")
                                            firstRecord.setValue(newPerson.date!, forKey: "date")
                                            firstRecord.setValue(newPerson.uniqID, forKey: "uniqID")

                                            do {
                                                try context.save()
                                            } catch {
                                            }
                                        }
                                    } catch {
                                    }
                                
                                }   //if loop
                            }
                        }   //for loop
                    }   // if contents received loop
                }  // if update file could not be downloaded.
            } // if url != nil loop
            

        }   //let task in loop
        
        task.resume() //Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
        
        refreshControl.endRefreshing()              //Stop spinner as download has finished.
        sleep(1)                //Not sure why this is needed but it is.

        fetchData()
        tableView.reloadData()  //Update the displayed data.

        navigationItem.prompt = "Number of shark attacks: \(workingData.count)"
        AudioServicesPlayAlertSound(SystemSoundID(1322))        //Make it beep after the update.
        
    }

//              ==============================================================
    
//Configure number of rows.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workingData.count
    }
    
//Configure cell data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        name = workingData[indexPath.row].name!
        area = workingData[indexPath.row].area!
        year = workingData[indexPath.row].year!
        country = workingData[indexPath.row].country!
        location = workingData[indexPath.row].country!
        
//Determine order of attribute to display.  We have 3 lines of text for each cell.  Case 0 is the default.
        switch searchMenuOptionSelected {
        case 0:
            cell.textLabel?.text = year + "\n" + "   " + country + " " + area + " " + "\n" + name
        case 1:
            cell.textLabel?.text = name + "\n" + "   " + country + " " + area + " " + year
        case 2:
            cell.textLabel?.text = country + "\n" + "   " + area + " " + year + " " + name
        case 3:
            cell.textLabel?.text = area + "\n" + "   " + country + " " + year + " " + name
        case 4:
            cell.textLabel?.text = location + "\n" + area + "   " + country + " " + year + " " + name
        default:
            cell.textLabel?.text = workingData[indexPath.row].name
        }

//Display row with a pale pink background if the shark incident was fatal else pale blue if non fatal
        switch workingData[indexPath.row].fatal! {
        case "Yes","YeS","YES","yes","Y","F","Fatal","FATAL","fatal":
            cell.backgroundColor = UIColor.init(red: 0.8 , green: 0.2, blue: 0.2, alpha: 0.2)
        default:
            cell.backgroundColor = UIColor.clear
        }
        
        return cell

    }
    
    //Fetch all data for display on main view.
    func fetchData() {
 
        let sortDescription = NSSortDescriptor(key: "uniqID", ascending: false)
        let fetchRequest = People.fetchRequest() as NSFetchRequest
 
        fetchRequest.sortDescriptors = [sortDescription]
        
        do {
            try items = context.fetch(fetchRequest)
        } catch  {
        }
        
        workingData = items!

    }

    //Delete all records.  Used for testing purposes
    func deleteAllData() {
        var recordCounter = 0
        for record in items! {
            
            print("Deleting record ",recordCounter)
            recordCounter += 1
            
            context.delete(record)
            do {
                try context.save()
            } catch {
            }
        }
        workingData = []                //Clear this out as we have no more data in our db.
        items = []
    }

    //Try and look up lat/long for a provided location.
    func latLongLookUP(location:String) -> String {
        
        let geoCoder = CLGeocoder()
        var locationCoords = "Unable to determine"   //Set as default
        
        geoCoder.geocodeAddressString(location) { (placemarks, error) in
            
            let placemarks = placemarks
            let coords = placemarks?.first?.location
            
            if coords != nil {
                locationCoords = "\(coords!)"
            }
        }
        
        return(locationCoords)
    }


    
    //Tapping on a record will display additional information.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        personRecordNumber = indexPath.row        //Row number that was tapped on.
        performSegue(withIdentifier: "showDetails", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        searchBar.resignFirstResponder()                                        //Dismiss keyboard.

//Displaying person details
        let detailsDestination = segue.destination as? DetailsTableViewController
        
        detailsDestination?.uniqID = workingData[personRecordNumber].uniqID

        //Mapping multiple incidents
        let mapDestination = segue.destination as? MapViewController
        
        mapDestination?.peopleDetails = workingData               //All the people to map.
        mapDestination?.searchText = textSearchedFor             //What was enterred into the search text box.
        mapDestination?.numberOfRecords = workingData.count        //Used to display at top of screen.
    }
}
