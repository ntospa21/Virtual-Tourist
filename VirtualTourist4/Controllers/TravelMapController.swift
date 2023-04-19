//
//  TravelMapController.swift
//  VirtualTourist4
//
//  Created by Pantos, Thomas on 6/4/23.
//

import UIKit
import CoreData
import MapKit

class TravelMapController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var pins: [Pin] = []
    var fetchedResultController:NSFetchedResultsController<Pin>!
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    
    
    fileprivate func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do{
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setPinsWithLongPress()
        setUpFetchedResultsController()
        remainingPins()

    }
    
    
    func setPinsWithLongPress(){
        let mapLongPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(_:)))
        mapLongPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(mapLongPress)
        saveViewContext()
    }
    
    
    @objc func addPin(_ recognizer: UIGestureRecognizer){
        if recognizer.state == .began {
            let touchedAt = recognizer.location(in: self.mapView)
            let newCoordinates: CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = newCoordinates.latitude
            pin.longitude = newCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = newCoordinates
            self.mapView.addAnnotation(annotation)
            do {
                try dataController.viewContext.save()
            } catch {
                showAlert(title: error.localizedDescription, message: "Something went bad")
            }
            pins.append(pin)
        }
    }
    func addCustomPin(_ coordinate: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        saveViewContext()
    }
    
    func showAlert(title: String , message: String){
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alertViewController, animated: true)
        
    }
    func saveViewContext(){
        try? dataController.viewContext.save()
    }
    
    func remainingPins(){
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        pins = fetchedResultController.fetchedObjects!
        for pin in pins {
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            addCustomPin(coordinate)
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumController")as! PhotoAlbumController
        let annotation = view.annotation
        //resource on navigate https://knowledge.udacity.com/questions/936976
            for pin in pins {
                if pin.latitude == annotation!.coordinate.latitude && pin.longitude == annotation!.coordinate.longitude {
                    photoAlbumController.pin = pin
                    
                    photoAlbumController.dataController = dataController
                    mapView.deselectAnnotation(view.annotation, animated: true)
                }

            }
    
        self.navigationController?.pushViewController(photoAlbumController, animated: true)

        
    }
}
