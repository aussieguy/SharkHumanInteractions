//
//  MapViewController.swift
//  SharkHumanInteractions5
//
//  Created by Glen Hobby on 14/2/21.
// Note: To zoom in the Simulator, hold Option and drag in the map view.

import UIKit
import MapKit       //To display map.

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
    var pinTitle: String?
    var pinSubtitle: String?
    var pinCoordinate: CLLocationCoordinate2D?
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView:MKMapView!       //Embedded map interface.

    //This information is passed through from DetailsTableViewController.
    var individualDetails = [String]()
    var numberOfRecords = Int()
    
    //This information is passed through from MainViewController
    var peopleDetails = [People]()
    let searchAttributes = ["year","name","country","state"]        //Search catergories.
    var searchText = ""                                             //What we are searching for.
    var fatalOrNonFatal = String()                                  //Determines what colour pin to display.
    var personName = ""
    var personYear = ""
    var locationDetails = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//We are mapping one incident.  Have segued from DetailsTableViewController
        if numberOfRecords == 1 {
            
            let locationNow = individualDetails[13]     //Latitude longitude coordinates.
            let locationCLL = stringToCLLocation(location: locationNow)
            
            fatalOrNonFatal = individualDetails[9]
            var status = String()
            
            switch fatalOrNonFatal {
            case "yes","Yes","YEs","YeS","YES":
                status = "Fatal"
            default:
                status = "Non fatal"
            }

//Set up parameters for nav bar text
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            navigationItem.largeTitleDisplayMode = .always
            
            
            
//Check if there is a flag at the end of this string which will indicate it's not an accurate location.
            if locationNow.hasSuffix(" F") {
                navigationItem.prompt = individualDetails[0] + " : " + "Warning: Location is not accurate!"
            } else {
                navigationItem.prompt = individualDetails[0]
            }

            navigationItem.title = individualDetails[8] + ", " + individualDetails[7] + ", " + status    //Display time, date then fatal or non fatal outcome.

            render(location: locationCLL, name: individualDetails[0], year: individualDetails[6], date: individualDetails[7], species: individualDetails[11], hourOfDay: individualDetails[8])
                        
        } else {

//We are mapping multiple incidents.  Have segued from MainViewController
            navigationItem.prompt = searchText            
            navigationItem.title = "Number of shark attacks: " + String(numberOfRecords)
            
            for personEntity in peopleDetails {
                
                locationDetails = personEntity.latitudelongitude!
                                
//Only try and place a pin on the map if there are lat long coordinates provided
                if locationDetails != "Unable to determine" {
                    
                    let locationCLL = stringToCLLocation(location: locationDetails)
                    
                    personName = personEntity.name!
                    personYear = personEntity.year!
                    let personDate = personEntity.date
                    fatalOrNonFatal = personEntity.fatal!
                    let sharkSpecies = personEntity.species!
                    let time = personEntity.time!
                    
                    render(location: locationCLL, name: personName, year: personYear, date: personDate!, species: sharkSpecies, hourOfDay: time )
                }
            }
        }        
    }
    
    func stringToCLLocation(location: String) -> CLLocation {
        
//Convert this string to a CLLocation variable so we can map it.
        var coordinate = CLLocation()
        let latLongString = location.components(separatedBy: "<")[1].components(separatedBy: ">")[0]
        
        let lat = latLongString.components(separatedBy: ",")[0]
        let long = latLongString.components(separatedBy: ",")[1]

        if let latitude =  Double(lat), let longitude = Double(long) {
             coordinate = CLLocation(latitude: latitude, longitude: longitude)
            return coordinate
        }
        
        return coordinate
    }
        
    func render(location: CLLocation, name: String, year: String, date: String, species: String, hourOfDay: String) {

        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)

        mapView.setRegion(region, animated: true)
        
        let customPin = MyPointAnnotation()

        customPin.coordinate = coordinate
        customPin.title = name + "\n" + year

        mapView.delegate = self     //Needed for custom pin on map.  MKMapViewDelegate is called to customise the pin.
        mapView.showsCompass = true
        mapView.showsScale = true
        
        switch fatalOrNonFatal {            //Determine colour of pin to show as well as callOut details
        case "yes","Yes","YEs","YeS","YES":
            customPin.subtitle = hourOfDay + ", " + date + ", " + "Fatal, " + species
            customPin.pinTintColor = .red
        default:
            customPin.subtitle = hourOfDay + ", " + date + ", " + "Non fatal, " + species
            customPin.pinTintColor = .blue
        }

        mapView.addAnnotation(customPin)
        
    }
    
    //This is the delegate method needed for a custom pin.  It is called by MKMapViewDelegate.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
        
        annotationView?.canShowCallout = true
        annotationView?.animatesDrop = true
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }
        
        return annotationView
    }    
}
