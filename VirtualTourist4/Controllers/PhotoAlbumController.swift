//
//  PhotoAlbumController.swift
//  VirtualTourist4
//
//  Created by Pantos, Thomas on 7/4/23.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumController : UIViewController, MKMapViewDelegate ,NSFetchedResultsControllerDelegate , UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin: Pin!
    var photos: [Photo] = []
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var urlsOfPho: [String] = []
    
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setMap()
        remainLastPin()
        setUpFetchedResultsController()
        newGets()
        
    }

    
    
    
    
   fileprivate func setUpFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
             let predicate = NSPredicate(format: "pin == %@", pin)
             fetchRequest.predicate = predicate
             let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
             fetchRequest.sortDescriptors = [sortDescriptor]
             
             fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
             fetchedResultsController.delegate = self
             
             do {
                 try fetchedResultsController.performFetch()
             } catch {
                 fatalError("The fetch couldn't be performed: \(error.localizedDescription)")
             }
         }
    
    
    
    

    func newGets(){
        FlickrClient.searchPhotos(latitude: pin.latitude, longitude: pin.longitude) { urls, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            self.urlsOfPho = urls


            for url in urls {
                FlickrClient.downloadPhoto(url: url ) { (data) in
                    let photo = self.savePhotoToCore(data: data)
                    self.photos.append(photo)
                    self.collectionView.reloadData()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                print(self.photos.count)

            }

        }
    }
    
    
    func savePhotoToCore(data: Data) -> Photo {
        //recources: https://knowledge.udacity.com/questions/907257
        let photo = Photo(context: self.dataController.viewContext)
        photo.image = data
        photo.pin = pin
        try? dataController.viewContext.save()
        
        return photo
    }
    
  


    
    
    
    func setMap(){
        
        //resources: https://stackoverflow.com/questions/31040667/zoom-in-on-user-location-swift
        let latDelta:CLLocationDegrees = 0.05
        let lonDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2DMake(pin!.latitude, pin!.longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: false)
    }
    
    func remainLastPin(){
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
  
    
    
    @IBAction func newCollectionTapped(_ sender: Any) {

       
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {

                print(self.photos.count)

            }
        }
        photos.removeAll()
        // have to clear out the array https://knowledge.udacity.com/questions/246943
        newGets()

        
    
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let data = photos[indexPath.row].image
        cell.imageView.image = UIImage(data: data!)

        return cell

      
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //resource idea https://knowledge.udacity.com/questions/718599
        photos.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
        let deleted = photos[indexPath.item]
        dataController.viewContext.delete(deleted)
        try? dataController.viewContext.save()
        print(photos.count)
        
    }
    
    
    
    
}
