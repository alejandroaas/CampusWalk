//
//  MapViewController.swift
//  CampusWalk
//
//  Created by Alejandro Andrade on 10/16/17.
//  Copyright © 2017 Alejandro Andrade. All rights reserved.
//

import UIKit
import MapKit


class DropPin : NSObject, MKAnnotation{
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let year: Int?
    let opcode: Int?
    @objc let imageName: String?
    @objc var image : UIImage?
    
    @objc init(title:String, coordinate:CLLocationCoordinate2D, year: Int, opcode: Int, imageName: String) {
        self.title = title
        self.coordinate = coordinate
        self.year = year
        self.opcode = opcode
        self.imageName = imageName
        self.image = UIImage()
    }
    
    static func ==(lhs:DropPin, rhs:DropPin) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    
    @objc var mapItem : MKMapItem {
        get {let placeMark = MKPlacemark(coordinate: coordinate)
            return MKMapItem(placemark: placeMark) }
    }
    @objc func setImage(image : UIImage){
        self.image = image
    }
}


class MapViewController: UIViewController, BuildingDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet weak var mapView: MKMapView!
    let campusMapModel = CampusMapModel.sharedInstance
    @objc var favs = [MKAnnotation]()
    @objc var pins = [DropPin]()
    @objc let locationManager = CLLocationManager()
    @objc var directionSource = [MKMapItem]()
    
    @IBOutlet weak var hideRoute: UIBarButtonItem!
    @IBOutlet weak var textViewList: UITextView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let center = campusMapModel.initialLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: span )
        mapView.region = region
        mapView.mapType = .standard
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled(){
            let status = CLLocationManager.authorizationStatus()
            switch status{
            case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                    mapView.showsUserLocation = true
                    locationManager.startUpdatingLocation()

            default:
                break
                
            }
        }
    }
    
    //MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            directionSource.removeAll()
            directionSource.append(MKMapItem.forCurrentLocation())
            
        default:
            mapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    //MARK: -Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "BuildingTableSegue":
            let buildingTableViewController = segue.destination as! BuldingsTableViewController
            buildingTableViewController.delegate = self
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
    func didChose(building : Building){
        dismiss(animated: true, completion: nil)
        showBuilding(building:building)
    
    }
    //MARK: -Buildings Delegate
    
    func showBuilding(building: Building){
        let coordinate = CLLocation(latitude: building.latitude, longitude: building.longitude)
        let pin = DropPin(title: building.name, coordinate: coordinate.coordinate, year: building.yearConstructed, opcode: building.code, imageName: building.photoName)
        if pins.contains(where: {$0 == pin  }) {

        }else{
            mapView.addAnnotation(pin)
            pins.append(pin)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center = coordinate.coordinate
        let region = MKCoordinateRegion(center: center, span: span )
        mapView.region = region
    }
    
    
    //MARK: - Actions
    @IBAction func standard(_ sender: Any) {
        mapView.mapType = .standard
    }
    @IBAction func satellite(_ sender: Any) {
        mapView.mapType = .satellite
    }
    @IBAction func removeAll(_ sender: Any) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        pins.removeAll()
    }
    
    @IBAction func HideRoute(_ sender: Any) {
        textView.isHidden = true
        textViewList.isHidden = true
        hideRoute.isEnabled = false
    }
    
    @IBAction func remove(_ sender: Any) {
        if !pins.isEmpty{
            self.mapView.removeAnnotation(pins.popLast()!)
        }
    }
    @IBAction func displayFavs(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if favs.count > 0{
            mapView.addAnnotations(favs)
        }
    }
    
    @IBAction func addToFavs(_ sender: Any) {
        if mapView.annotations.count > 0{
            for annotation in mapView.selectedAnnotations{
                favs.append(annotation)
            }
        }
    }
    @IBAction func Hybrid(_ sender: Any) {
        mapView.mapType = .hybrid
    }
    
    //MARK: - Image Pickker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let annotation = mapView.selectedAnnotations[0] as! DropPin
        mapView.removeAnnotation(annotation)
        annotation.image = image
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - Map View Delegates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is DropPin:
            return annotationView(pin: annotation as! DropPin)
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        switch view.annotation {
        case is DropPin:
            callOut(building: view.annotation as! DropPin)
        default:
            return
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch  overlay {
        case is MKPolyline:
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = .black
            polylineRenderer.lineWidth = 2.0
            polylineRenderer.alpha = 0.8
            return polylineRenderer
        case is MKCircle:
            assert(false,"Unhandled Renderer")
        default:
            assert(false,"Unhandled Renderer")
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (view.annotation?.title)! == "My Location"{
            let alert = UIAlertController(title: "Hi", message: "Directions To changed to current Location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
            directionSource.removeAll()
            directionSource.append(MKMapItem.forCurrentLocation())
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Callouts
    
    @objc func callOut(building: MKAnnotation){
        let actionSheet = UIAlertController(title: building.title!, message: nil, preferredStyle: .actionSheet)
        
        let directionsToAction = UIAlertAction(title: "Directions To", style: .default) { (action) in
            self.direction(building : building as! DropPin)
        }
        actionSheet.addAction(directionsToAction)
        
        let changeImageAction = UIAlertAction(title: "Change Bldg. Image", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            
        }
        actionSheet.addAction(changeImageAction)
    
        let directionsFromAction = UIAlertAction(title: "Directions From", style: .default) { (action) in
            let bldgDropPin = building as! DropPin
            self.directionSource.removeAll()
            self.directionSource.append(bldgDropPin.mapItem)
        }
        
        actionSheet.addAction(directionsFromAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @objc func direction(building : DropPin) {
        guard mapView.showsUserLocation else {return}
        let request = MKDirectionsRequest()
        mapView.removeOverlays(mapView.overlays)
        request.destination = building.mapItem
        request.source = directionSource.first
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            guard error == nil else {print(error?.localizedDescription ?? "Error"); return}
            
            if let route = response?.routes[0] {
                self.mapView.add(route.polyline)
                let steps = route.steps
                self.displaySteps(steps:steps, eta: route.expectedTravelTime)
            }
            
        }
        

        
    }
    @objc func displaySteps(steps : [MKRouteStep], eta: Double) {
        let alert = UIAlertController(title: "Display Steps?", message: "ETA \(eta) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "On the map", style: .default,handler: { action in
            self.onMapRoute(steps: steps)
        }))
        alert.addAction(UIAlertAction(title: "List", style: .default,handler:{action in
            self.listRoute(steps:steps)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onMapRoute(steps: [MKRouteStep]){
        textView.text = ""
        textView.isHidden = false
        for step in steps{
            textView.insertText(step.instructions + "\n");
        }
        hideRoute.isEnabled = true
    }
    @objc func listRoute(steps: [MKRouteStep]){
        textViewList.text = ""
        for (i, step) in steps.enumerated(){
            textViewList.isHidden = false
            textViewList.insertText("\(i+1). \(step.instructions)\n");
        }
        hideRoute.isEnabled = true
    }
    //MARK: - AnnotationViews functions for adding to map
    
    @objc func annotationView(pin : DropPin) -> MKAnnotationView {
        let identifier = "DropPin"
        var annotationView : MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            dequeuedView.annotation = pin
            annotationView = dequeuedView
        }else{
            annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            if pin.imageName == ""{
                annotationView.image = UIImage(named: "buildingIcon")
            }else{
                let image = UIImage(named: pin.imageName!)
                annotationView.image = image?.resizeImage(targetSize: CGSize(width: 50, height: 50))
            }
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let imageView = UIImageView(image: UIImage(named: pin.imageName!))
            imageView.contentMode = .scaleAspectFit
            imageView.frame.size = CGSize(width: 50, height: 50)
            annotationView.leftCalloutAccessoryView = imageView//change this for image
        }
        return annotationView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
