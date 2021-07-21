import UIKit
import CoreData

// This method is called in ViewController which manages the splash screen.
// It is run the first time the app is run and loads data into the database.
//

var items:[People]?         //Data to be retrieved

func readSharkDataFile() {
    let checkForTheseNames = ["male","Male","female","Female","","A dinghy"] //Don't allow as a name.
    let doubleQuoteChar:Character = "\""
    var sharkArray = [String]()
    var uniqID:Int64 = 6472              //CoreData record counter used to look up person details.
    let firstRecord = UserDefaults.standard //Save most current record for display on launch screen.
    var firstRecordIsBeingRead = true       //Used when updating.
    
    //Create the file path to the data file.
    guard let filepath = Bundle.main.path(forResource: "sharkAttacks_up_to_end_of_2020", ofType: "csv") else {
        return
    }

//Try and read in the sharkAttack file
    do {
        let sharkFile = try String(contentsOfFile: filepath)
        sharkArray = sharkFile.components(separatedBy: "\n")        //Record separator
        sharkArray.removeFirst(1)       //Header information only.  Don't need.
    } catch {
    }
    
//Each array cell holds a string record.  Take each cell and turn it into an array.
    for stringIncident in sharkArray {
        if !stringIncident.isEmpty {            //At the end of our data are empty spreadsheet rows.  Don't process these.
            
            /// Need to change text that looks like this:  quick, brown, "Fox, jumped, over",the         into         quick, brown, Fox jumped over,the,lazy
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
            if newSharkArray[1] != "" {
                
                //We don't want gender in these columns.
                if checkForTheseNames.contains(newSharkArray[8]) {
                    newSharkArray[8] = "Name not provided"
                }
//Create a new Person object
                let newPerson = People(context: context)
                
                newPerson.date = newSharkArray[1]
                newPerson.year = newSharkArray[2]
                newPerson.type = newSharkArray[3]
                newPerson.country = newSharkArray[4]
                newPerson.area = newSharkArray[5]
                newPerson.location = newSharkArray[6]
                newPerson.activity = newSharkArray[7]
                newPerson.name = newSharkArray[8]
                
                switch newSharkArray[9] {
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
                
                newPerson.age = newSharkArray[10]
                newPerson.injury = newSharkArray[11]
                
                switch newSharkArray[12] {
                case "Y":
                    newPerson.fatal = "Yes"
                case "F":
                    newPerson.fatal = "Yes"
                case "N":
                    newPerson.fatal = "No"
                case "M":
                    newPerson.fatal = "No"
                default:
                    newPerson.fatal = "Unknown"
                }

                newPerson.time = newSharkArray[13]
                newPerson.species = newSharkArray[14]
                newPerson.uniqID = uniqID
                newPerson.latitudelongitude = "Unable to determine"     //Set default value.
                
                //Only save this new record if it is not already on file.
                if items?.count != nil {
                    if !items!.contains(newPerson) {
                        items!.append(newPerson)
                    }
                } else {
                    items?.insert(newPerson, at: 0)
                }
                
                if firstRecordIsBeingRead {
                    firstRecordIsBeingRead = false

                    firstRecord.setValue(newPerson.name!, forKey: "name")       //Set values.
                    firstRecord.setValue(newPerson.date!, forKey: "date")
                    firstRecord.setValue(newPerson.year!, forKey: "year")
                    firstRecord.setValue(newPerson.country!, forKey: "country")
                    firstRecord.setValue(newPerson.location!, forKey: "location")
                    firstRecord.setValue(newPerson.area!, forKey: "area")
                    
                }
                
                do {
                    try context.save()
                    
//print("Creating : ",newPerson.name!,newPerson.year!)
                    uniqID -= 1         //Person record counter.
                } catch  {
                }
                
                
            }   //if loop
        }   // if string != "" loop
    }   //for loop
    
    retrieveLatLong()       //Write latitudeLongitude and uniqID to person's record.

}

//Read LatAndLong.txt and write it's details to CoreData.  We are identifying the record by uniqID
func retrieveLatLong() {
    var latLongArray = [String]()

    //Create the file path to the latitude longitude data file.
    guard let filepath = Bundle.main.path(forResource: "LatAndLong", ofType: "txt") else {
        return
    }
    
    //Read the file.
    do {
        let latLongFile = try String(contentsOfFile: filepath)
        
        latLongArray = latLongFile.components(separatedBy: "\n")        //Store each line of the file as an array entry.
    } catch {
    }
    
//Read through each line, extract the uniqID and the latitudeLongitude.  Format is: uniqID latitudelongitude.  Last line is empty
// 6451 <-31.85920040,+115.77481730> +/- 100.00m
    var lineCounter = 0

    while lineCounter < latLongArray.count - 1 {
        
        var uniqIDString = String()
        var uniqIDInt64 = Int64()
        var latitudeLongitude = String()
        let lineOfInterest = latLongArray[lineCounter]      //Get the line
        
        for characters in lineOfInterest {
            
            if characters == " " {
                break                                           //Exit for loop as we now have the uniqID
            }
            
            uniqIDString = uniqIDString + "\(characters)"        //This will make it a string
        }

        uniqIDInt64 = Int64(uniqIDString)!         //uniqID
        
        var skipCharacterCounter = 0
        
        for characters in lineOfInterest {
            
            //We need to skip the first uniqIDString.count characters, then +1 then we now have the latitudeLongitude
            if skipCharacterCounter > uniqIDString.count {
                latitudeLongitude = latitudeLongitude + "\(characters)"         //latitudeLongitude
            }
            
            skipCharacterCounter += 1
        }
        
        //Retrieve this person's record from CoreData, update the latLong and then write it back.
        let fetchRequest = People.fetchRequest() as NSFetchRequest
        fetchRequest.predicate = NSPredicate(format: "uniqID = %i", uniqIDInt64)
        do {
            try items = context.fetch(fetchRequest)
        } catch  {
        }
        
        let personToUpdate = items![0]
        personToUpdate.latitudelongitude = latitudeLongitude

        //Save this person's record with the updated latitudelongitude field
        do {
            try context.save()
        } catch {
        }

        lineCounter += 1
    }       //While loop

    
}
