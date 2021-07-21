//
//  SettingsTableViewController.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 14/6/21.
//

import UIKit
import MessageUI        //Enable sending an email to the developer

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var feedbackButton: UIButton!
    @IBAction func sendEmail(_ Sender: Any) {
        
//Only try and send an email if this is configured on the device
        if MFMailComposeViewController.canSendMail() {
            
            let emailAddress = URL(string: "mailto:gemvalidate1@gmail.com")
            
            UIApplication.shared.open(emailAddress!)
        }
    }

    let numberOfRows = 6
    
    let questions = ["How do I check for new data?","How do I reinstall the data?","Will downloading new data erase any changes I've made to existing data?","How do I make changes?","How do I enter latitude longitude data?","Why are some location pins inaccurate?"]
    let answers = ["Swipe down on the main screen to updata data.","Delete the app then download it again. First time the app runs it will reload data. Swipe down to update.","No. New downloads do not impact upon any changes you've made to existing records.","Select the record you wish to edit then tap on any of the fields to change.","Change the Country, State and Location data to a nearby town. When the record is saved the app will try and look up the latitude longitude of this information if it is available.","To improve accuracy, change the location to the nearest town."]
    
    override func viewDidLoad() {
        super.viewDidLoad()

//Set up a background image for the tableView
        let backgroundImage = "Shark.jpg"
        let image = UIImage(named: backgroundImage)
        let imageView = UIImageView(image: image)
        
        tableView.backgroundView = imageView
        tableView.backgroundView?.alpha = 0.3

//Check that email can be sent from device and if so display a feedback button.
        if MFMailComposeViewController.canSendMail() {
            
            feedbackButton.setTitle("Feedback", for: .normal)
        }

    }

 
//Configure number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

//Configure number of row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

//Configure cell data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)

        cell.textLabel?.text = questions[indexPath.row] + "\n" + "   " + answers[indexPath.row]
        cell.backgroundColor = UIColor.clear

        return cell
    }

}
