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

final class MapController: UIViewController {
    
    lazy private var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .large
        return indicator
    }()
    
    lazy private var mapView: GMSMapView = {
        var view = GMSMapView()
        let camera = GMSCameraPosition(
            latitude: 53.899986473284805,
            longitude: 27.55533492413279,
            zoom: 10.5
        )
        let mapID = GMSMapID(identifier: Constants.GMSMAPID)
        view = GMSMapView(
            frame: self.view.frame,
            mapID: mapID,
            camera: camera
        )
        view.delegate = self
        return view
    }()
    
    private var user = Auth.auth().currentUser
    var places = RealmManager<SSPlace>().read()
    var markers = [GMSMarker]()
    var studios = [GMSPlace]()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super .init(nibName: nil, bundle: nil)
        setupVC()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detectFirstLaunch()
        drawMarker()
        getStudios()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: VC setup
    private func setupVC() {
        self.view.addSubview(mapView)
        self.view.addSubview(spinner)
        self.view.sendSubviewToBack(mapView)
    }
    
    private func makeConstraints() {
        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
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
                longitude: place.coordinatesLng
                )
            )
            
            marker.userData = place
            marker.map = mapView
            markers.append(marker)
        }
    }
    
    private func getLike(
        studio: GMSPlace,
        succed: @escaping BoolBlock
    ) {
        guard let studioID = studio.placeID,
              let userID = user?.uid else { return }
        FirebaseUserManager.getLike(
            referenceType: .getLike(
                userID: userID,
                studioID: studioID
            )
        ) { like in
            succed(like)
        }
    }

    
    //MARK: Present sheet StudioInfoController
    private func presentSheetInfoController(studio: GMSPlace) {
        self.spinner.startAnimating()
        getLike(studio: studio) { like in
            let infoVC = StudioInfoController(
                nibName: String(describing: StudioInfoController.self),
                bundle: nil
            )

            infoVC.set(studio: studio, likeFromFir: like)
            infoVC.isModalInPresentation = true
            self.present(infoVC, animated: true)
            self.spinner.stopAnimating()
        }
    }
}


//MARK: GMSMapViewDelegate
extension MapController: GMSMapViewDelegate {
    
    func mapView(
        _ mapView: GMSMapView,
        didTapAt coordinate: CLLocationCoordinate2D
    ) {
        dismiss(animated: true)
    }
    
    func mapView(
        _ mapView: GMSMapView,
        didTap marker: GMSMarker
    ) -> Bool {

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
        SSPlace().createStudios()
    }
    
    //MARK: Get Info From PlaceID
    private func getStudios(placeID: String) {
        GetStudiosAPI.getInfoFromPlaceId(placeID: placeID) {
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

