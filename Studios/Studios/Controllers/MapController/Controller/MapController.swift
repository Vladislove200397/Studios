//
//  ViewController.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 8.11.22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class MapController: UIViewController {
    var places = RealmManager<SSPlace>().read()
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private var user = Auth.auth().currentUser
    var markers = [GMSMarker]()
    var studios = [GMSPlace]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        detectFirstLaunch()
        cameraOnMinsk()
        drawMarker()
        getStudios()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Camera setup
    private func cameraOnMinsk() {
        let minsk =
        CLLocationCoordinate2D(latitude: 53.899986473284805,
                               longitude: 27.55533492413279)
        
        mapView.camera = GMSCameraPosition(target: minsk,
                                           zoom: 10.5)
    }
    
    private func cameraZoomOnTap(coordinate: CLLocationCoordinate2D) {
        let camera =
        GMSCameraPosition(latitude: coordinate.latitude,
                          longitude: coordinate.longitude,
                          zoom: 18)
        mapView.animate(to: camera)
    }
    
    private func drawMarker() {
        places.enumerated().forEach { (name, place) in
            let marker =
            GMSMarker(position: CLLocationCoordinate2D(
                    latitude: place.coordinatesLat,
                    longitude: place.coordinatesLng))
            
            marker.userData = place
            marker.map = mapView
            markers.append(marker)
        }
    }
    
    //MARK: Present sheet StudioInfoController
    private func presentSheetInfoController(studio: GMSPlace) {
        let infoVC = StudioInfoController(nibName: String(describing: StudioInfoController.self), bundle: nil)

        infoVC.set(studio: studio)
        infoVC.isModalInPresentation = true
        present(infoVC, animated: true)
    }
}

//MARK: GMSMapViewDelegate
extension MapController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        dismiss(animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        mapView.animate(toLocation: CLLocationCoordinate2D(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude))
        
        mapView.selectedMarker = marker
        
        cameraZoomOnTap(coordinate: CLLocationCoordinate2D(
            latitude: marker.position.latitude,
            longitude: marker.position.longitude))
        dismiss(animated: true)
        
        if let place = marker.userData as? SSPlace {
            guard let studio = studios.first(where: {$0.placeID == place.placeID}) else { return true }
            presentSheetInfoController(studio: studio)
        }
        return true
    }
}

//MARK: Studios Place ID
extension MapController {
    private func addingPlaces() {
        
        let paradise = SSPlace(
            placeID: "ChIJRyjZzk3P20YR5OzgUsh9Zt0",
            coordinatesLat: 53.89008190576222,
            coordinatesLng: 27.56942121154621
        )
        
        let diva = SSPlace(
            placeID: "ChIJpaqYN9DP20YR73hF4NmE6t8",
            coordinatesLat: 53.890056770971995,
            coordinatesLng: 27.5699165455818
        )
        
        let trueman = SSPlace(
            placeID: "ChIJaxs5X2_P20YRaQjKTdEGmrk",
            coordinatesLat: 53.88589806270611,
            coordinatesLng: 27.581649364152707
        )
        
        let prosto = SSPlace(
            placeID: "ChIJeUKnNpbP20YRlnkX8rcjtcM",
            coordinatesLat: 53.88575574363853,
            coordinatesLng: 27.58150470537655
        )
        
        RealmManager<SSPlace>().write(object: diva)
        RealmManager<SSPlace>().write(object: paradise)
        RealmManager<SSPlace>().write(object: trueman)
        RealmManager<SSPlace>().write(object: prosto)
    }
    //MARK: Get Info From PlaceID
    func getInfoFromPlaceId(placeID: String) {
         let placeId = placeID
         let placesClient = GMSPlacesClient()
         let fields:
        GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                UInt(GMSPlaceField.rating.rawValue) |
                                                UInt(GMSPlaceField.formattedAddress.rawValue) |
                                                UInt(GMSPlaceField.placeID.rawValue) |
                                                UInt(GMSPlaceField.userRatingsTotal.rawValue) |
                                      UInt(GMSPlaceField.photos.rawValue) |
                                      UInt(GMSPlaceField.phoneNumber.rawValue) |
                                      UInt(GMSPlaceField.website.rawValue) |
                                      UInt(GMSPlaceField.utcOffsetMinutes.rawValue) |
                                      UInt(GMSPlaceField.openingHours.rawValue) |
                                      UInt(GMSPlaceField.coordinate.rawValue))

         placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: { (place: GMSPlace?, error: Error?) in

             if let error = error {
                 print("ERROR \(error.localizedDescription)")
             }
             guard let place = place else { return }
             Service.shared.studios.append(place)
             self.studios = Service.shared.studios
         })
     }
    
    private func getStudios() {
        places.forEach { studio in
            getInfoFromPlaceId(placeID: studio.placeID)
        }
    }
    //MARK: Detect first launch
    private func detectFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
        } else {
            addingPlaces()
            places = RealmManager<SSPlace>().read()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
}

