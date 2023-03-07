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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    lazy var mapView: GMSMapView = {
        var view = GMSMapView()
        let camera = GMSCameraPosition(latitude: 53.899986473284805, longitude: 27.55533492413279, zoom: 10.5)
        let mapID = GMSMapID(identifier: "6fc961a7a5cfbbfa")
        view = GMSMapView(frame: self.view.frame, mapID: mapID, camera: camera)
        return view
    }()
    
    private var user = Auth.auth().currentUser
    var places = RealmManager<SSPlace>().read()
    var markers = [GMSMarker]()
    var studios = [GMSPlace]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        detectFirstLaunch()
        setupVC()
        drawMarker()
        getStudios()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: VC setup
    private func setupVC() {
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
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
    
    private func getLike(studio: GMSPlace, succed: @escaping (Bool) -> Void) {
        guard let studioID = studio.placeID,
              let userID = user?.uid else { return }
        FirebaseProvider().getLike(referenceType: .getLike(userID: userID, studioID: studioID)) { like in
            succed(like)
        }
    }

    
    //MARK: Present sheet StudioInfoController
    private func presentSheetInfoController(studio: GMSPlace) {
        self.spinner.startAnimating()
        getLike(studio: studio) { like in
            let infoVC = StudioInfoController(nibName: String(describing: StudioInfoController.self), bundle: nil)
            
            infoVC.set(studio: studio, likeFromFir: like)
            infoVC.isModalInPresentation = true
            self.present(infoVC, animated: true)
            self.spinner.stopAnimating()
        }
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
    private func getStudios(placeID: String) {
        GetStudiosAPI().getInfoFromPlaceId(placeID: placeID) {
            self.studios = Service.shared.studios
        }
    }
    
    private func getStudios() {
        places.forEach { studio in
            getStudios(placeID: studio.placeID)
        }
    }
    //MARK: Detect first launch
    private func detectFirstLaunch() {
        UserDefaultsManager.detectFirstLaunch { launchBefore in
            if !launchBefore {
                self.addingPlaces()
                self.places = RealmManager<SSPlace>().read()
                UserDefaultsManager.userDefaultsManager.set(true, forKey: "launchedBefore")
            }
        }
    }
}

