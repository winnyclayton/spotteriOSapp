//
//  MainHomeViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 5/6/2023.
//

import CoreLocation
import UIKit
import GoogleMaps


class MainHomeViewController: UIViewController, GMSMapViewDelegate{
    
    var mapView: GMSMapView?
    let locationManager = CLLocationManager()
    var markerDetailViewController: MarkerDetailViewController?
    
    var locationForecast: [LocationForecastResponse] = []
    
    var locationIds: [Int] = []
    
    //property to see if distance and duration has been fetched
    var isDistanceDurationFetched = false
        
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //current location authorise
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //depending what user selecte
        let locationTrackingEnabled = UserDefaults.standard.bool(forKey: "LocationTrackingEnabled")
        // Start or stop location tracking based on user's choice
        if locationTrackingEnabled {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }

        willyWeatherAPI = WillyWeatherAPI()
        
        GMSServices.provideAPIKey("AIzaSyDZNlu3kX7Cv9cyJXX1o_36OZXvj8UkMqk")
        
        let camera = GMSCameraPosition(latitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView(frame: view.frame, camera: camera)
        
        //fetch data for userSelectedLocations and userLocations
        if let api = willyWeatherAPI {
            api.fetchData { locationForecasts in
                DispatchQueue.main.async {
                    if !locationForecasts.isEmpty {
                        //successfully fetched location forecasts
                        self.locationForecast = locationForecasts
                        
                        //print("Testing homepage", locationForecasts)
                        
                        for forecast in locationForecasts {
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(forecast.location.lat), longitude: CLLocationDegrees(forecast.location.lng))
                            marker.map = self.mapView
                            
                            //replace marker icon
                            if let customImage = UIImage(named: "mapMarkers") {
                                marker.icon = customImage
                            }
                        }
                        
                    } else {
                        //handle the case where no location forecasts were retrieved
                        print("No location forecasts found.")
                    }
                }
            }
        }
        
        
        //for the pop up
        mapView?.delegate = self
        
        mapView?.settings.zoomGestures = true
        view.addSubview(mapView!)
        
        //spotter logo
        let logoImageView = UIImageView(image: UIImage(named: "SpotterMapLogo"))
        logoImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        logoImageView.contentMode = .scaleAspectFit
        mapView?.addSubview(logoImageView)
        mapView?.bringSubviewToFront(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: mapView!.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: mapView!.topAnchor, constant: 70)
        ])
        
        //adverstisment space
        let fixedImageView = UIImageView(image: UIImage(named: "BCFAd"))
        fixedImageView.contentMode = .scaleAspectFit
        view.addSubview(fixedImageView)
        
        fixedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenHeight = UIScreen.main.bounds.height
        //divide screen into 8 rows and show image on the 6th row
        let sixthRowYPosition = screenHeight / 8 * 6
        
        NSLayoutConstraint.activate([
            fixedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fixedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fixedImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: sixthRowYPosition), // Position in the 5th row
            fixedImageView.heightAnchor.constraint(equalToConstant: 60.0) // Set the height to 30 points
        ])
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
            
            // Ensure the view is loaded before updating the data
            markerDetailViewController?.loadViewIfNeeded()
            markerDetailViewController?.userLocation = locationManager.location // Set user location first
            markerDetailViewController?.updateData(with: tappedLocationForecast)
            // Set the tapped location forecast for handling directions
            markerDetailViewController?.tappedLocationForecast = tappedLocationForecast
        }
        
        // Set the presentation style to full screen
        markerDetailViewController?.modalPresentationStyle = .overFullScreen
        
        // Set the background color to transparent
        markerDetailViewController?.view.backgroundColor = UIColor.clear
        
        present(markerDetailViewController!, animated: true, completion: nil)
        
        return true
    }
    //END OF DETAIL POP UP
}


extension MainHomeViewController: CLLocationManagerDelegate {
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
}
    
    
    






