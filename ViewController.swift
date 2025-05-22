//
//  ViewController.swift
//  TravelBookLastV
//
//  Created by Ali Ünal UZUNÇAYIR on 20.05.2025.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var commentTxt: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    var userLatitude = Double()
    var userLongitude = Double()
    
    var annatationTLatetude = Double()
    var annatationTLongitude = Double()
    var selectedNmae = ""
    var selectedId : UUID?
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if selectedNmae != "" {
            saveButton.isEnabled = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let stringId = selectedId?.uuidString
            fetchReq.returnsObjectsAsFaults = false
            fetchReq.predicate = NSPredicate(format: "id == %@",stringId! )
        
            do {
                let result = try context.fetch(fetchReq)
                for res in result as! [NSManagedObject] {
                    if let name = res.value(forKey: "title") as? String
                    {
                        nameTxt.text = name
                        if let comment = res.value(forKey: "subtitle") as? String{
                            commentTxt.text = comment
                            if let chosenLatetude = res.value(forKey: "latitude") as? Double {
                                annatationTLatetude = chosenLatetude
                                if let chosenLongtude = res.value(forKey: "longitude") as? Double {
                                    annatationTLongitude = chosenLongtude
                                
                                }
                            }
                        }
                  }
                }
                let annatation = MKPointAnnotation()
                annatation.coordinate = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
                annatation.title = nameTxt.text
                annatation.subtitle = commentTxt.text
                self.mapView.addAnnotation(annatation)
                let location = CLLocationCoordinate2D(latitude: annatationTLatetude, longitude: annatationTLongitude)
                annatation.coordinate = location
                mapView.addAnnotation(annatation)
  
                locationManager.stopUpdatingLocation()
                
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location, span: span)
                mapView.setRegion(region, animated: true)
                
             
                
                
            }catch{
                print("eror when fetching data to viewController")
            }
        //anotaation
            
        }
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedNmae != ""{
            
         var reqLocation = CLLocation(latitude: annatationTLatetude, longitude: annatationTLongitude)
        }
        
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        
        
        
        return pinView
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedNmae == ""{
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        else {
            
            
        }
        
    }
    /*     •    Bu fonksiyon, kullanıcının konumu güncellendikçe otomatik olarak çalışır.
     •    locations[0]: En son bilinen konumu alır.
     •    CLLocationCoordinate2D: Enlem ve boylamdan oluşan koordinat nesnesi oluşturur.
     •    MKCoordinateSpan: Haritanın ne kadar alanı göstereceğini belirler. Delta ne kadar küçükse, yakınlaştırma o kadar fazladır.
     •    MKCoordinateRegion: Haritada gösterilecek alanı tanımlar (merkez konum + yakınlaştırma seviyesi).
     •    mapView.setRegion(region, animated: true): Haritanın gösterdiği bölgeyi, güncel konuma kaydırır ve animasyonla gösterir.*/
    
    @objc func addPin(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            userLatitude = touchedCoordinate.latitude
            userLongitude = touchedCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = nameTxt.text
            annotation.subtitle = commentTxt.text
            mapView.addAnnotation(annotation)
        }
    }
    @IBAction func saveButtonClik(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPalace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPalace.setValue(nameTxt.text, forKey:"title")
        newPalace.setValue(commentTxt.text, forKey:"subtitle")
        newPalace.setValue(userLatitude, forKey: "latitude")
        newPalace.setValue(userLongitude, forKey: "longitude")
        newPalace.setValue(UUID(), forKey: "id")
      
        do {try context.save()
            print("save button success")
        }catch {
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
    }
    
    
}
