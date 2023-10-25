//
//  SunResultsViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 2/8/2023.
//

import CoreLocation
import UIKit
import GoogleMaps

class SunResultsViewController: UIViewController, GMSMapViewDelegate{
    
    var mapView: GMSMapView?
    let locationManager = CLLocationManager()
    var markerDetailViewController: MarkerDetailViewController?
    
    var locationForecast: [LocationForecastResponse] = []
    var locationNames: [String] = []
    var locationIds: [Int] = []
    
    var selectedDate: Date?
    var selectedArea: String?
    
    var dataToDisplay: (locationNames: [String], locationForecasts: [LocationForecastResponse])?
    
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var mapViewResults: UIView!
    @IBOutlet weak var userSelected: UILabel!
    
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        willyWeatherAPI = WillyWeatherAPI()
        
        GMSServices.provideAPIKey("AIzaSyDZNlu3kX7Cv9cyJXX1o_36OZXvj8UkMqk")
        
        let nswCenterLatitude: CLLocationDegrees = -28.0
        let nswCenterLongitude: CLLocationDegrees = 146.0
        
        let camera = GMSCameraPosition(latitude: nswCenterLatitude, longitude: nswCenterLongitude, zoom: 6.0)
        mapView = GMSMapView(frame: mapViewContainer.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //for the pop up
        mapView?.delegate = self
        
        mapView?.settings.zoomGestures = true
        mapViewContainer.addSubview(mapView!)
        
        if let data = dataToDisplay {
            locationNames = data.locationNames
            locationForecast = data.locationForecasts
            addMarkersToMap()
        }
        
        if let selectedDate = selectedDate, let selectedArea = selectedArea {
            let formattedDate = formatDate(selectedDate)
            userSelected.text = "\(selectedArea)   \(formattedDate)"
        }
    }
        
    //MARKER DETAIL POP UP
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if markerDetailViewController == nil {
            markerDetailViewController = storyboard.instantiateViewController(withIdentifier: "MarkerDetailViewController") as? MarkerDetailViewController
        }
        
        markerDetailViewController?.markerTitle = marker.title
        markerDetailViewController?.markerSnippet = marker.snippet
        
        if let tappedLocationForecast = locationForecast.first(where: {marker.position.latitude == CLLocationDegrees($0.location.lat) && marker.position.longitude == CLLocationDegrees($0.location.lng)}) {
            
            //make sure view is loaded before updating data
            markerDetailViewController?.loadViewIfNeeded()
            markerDetailViewController?.userLocation = locationManager.location //set user location first
            markerDetailViewController?.updateData(with: tappedLocationForecast)
            //set the tapped location forecast for handling directions
            markerDetailViewController?.tappedLocationForecast = tappedLocationForecast
        }

        //set presentation style to full screen
        markerDetailViewController?.modalPresentationStyle = .overFullScreen
        
        //set the background color to transparent
        markerDetailViewController?.view.backgroundColor = UIColor.clear
        
        present(markerDetailViewController!, animated: true, completion: nil)
        
        return true
    }

    //END OF DETAIL POP UP
    @IBAction func backToListTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
}
    
    
    extension SunResultsViewController: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let mapView = mapView else { return }
            let camera = GMSCameraPosition(latitude: locations[0].coordinate.latitude,
                                           longitude: locations[0].coordinate.longitude,
                                           zoom: 15.0)
            if mapView.superview == nil {
                mapView.camera = camera
                mapView.isMyLocationEnabled = true
                mapView.settings.myLocationButton = true
                view.addSubview(mapView)
                
            }
        }
        
        //add markers to map
        func addMarkersToMap() {
            guard let mapView = mapView else { return }
            
            print ("Number of location forecasts: \(locationForecast.count)")
                   
            for locationForecast in locationForecast {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationForecast.location.lat),
                                                         longitude: CLLocationDegrees(locationForecast.location.lng))
                marker.title = locationForecast.location.name
                marker.map = mapView
                
                //replace marker icon
                if let customImage = UIImage(named: "mapMarkers") {
                    marker.icon = customImage
                }
            }
        }
        
        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE MMM d"
            return dateFormatter.string(from: date)
        }
        
    }
