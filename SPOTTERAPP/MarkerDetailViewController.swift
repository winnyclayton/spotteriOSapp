//
//  MarkerDetailViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 26/6/2023.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Foundation

//struct for googlematrix
struct GoogleDistanceMatrixResponse: Codable {
    let status: String
    let rows: [DistanceMatrixRow]
}

struct DistanceMatrixRow: Codable {
    let elements: [DistanceMatrixElement]
}

struct DistanceMatrixElement: Codable {
    let distance: Distance?
    let duration: Duration?
    let status: String
}

struct Distance: Codable {
    let text: String
    let value: Int
}

struct Duration: Codable {
    let text: String
    let value: Int
}

class MarkerDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var sunTab: UIButton!
    @IBOutlet weak var waveTab: UIButton!
    @IBOutlet weak var mapLocationName: UILabel!
    @IBOutlet weak var mapLocationRainfall: UILabel!
    @IBOutlet weak var mapLocationLowTemp: UILabel!
    @IBOutlet weak var mapLocationHighTemp: UILabel!
    @IBOutlet weak var mapLocationPrecis: UILabel!
    @IBOutlet weak var mapLocationWind: UILabel!
    @IBOutlet weak var mapLocationHours: UILabel!
    @IBOutlet weak var mapLocationKlms: UILabel!
    @IBOutlet weak var homePageDirections: UIImageView!
    
    var markerTitle: String?
    var markerSnippet: String?
    
    var didUpdateUserLocation = false
    
    var tappedLocationForecast: LocationForecastResponse?
    
    private var initialTouchPoint: CGPoint = CGPoint.zero
    private let dismissThreshold: CGFloat = 100.0
    
    var userLocation: CLLocation? //store the users current location here
    var locationManager: CLLocationManager?
    var locationForecast: [LocationForecastResponse] = []
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize and configure the location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        modalPresentationStyle = .overCurrentContext
        
        //add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        // ad tap gesture recognizer to the homePageDirections image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDirectionsTap))
        homePageDirections.addGestureRecognizer(tapGesture)
        homePageDirections.isUserInteractionEnabled = true
    }
    
    //when directions image is tapped, perform this method
    @objc private func handleDirectionsTap() {
        print("homePageDirections tapped")
        
        if let userLocation = userLocation, let destination = tappedLocationForecast?.location {
            //ppen Google Maps using stored data
            let googleMapsURL = "comgooglemaps://?saddr=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&daddr=\(destination.lat),\(destination.lng)&directionsmode=driving"
            
            if let url = URL(string: googleMapsURL) {
                //check if google maps app is installed
                if UIApplication.shared.canOpenURL(url) {
                    //open the google maps app
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    //google maps app not installed, open in Safari
                    let safariURL = "https://www.google.com/maps/dir/?api=1&origin=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&destination=\(destination.lat),\(destination.lng)&travelmode=driving"
                    if let safariURL = URL(string: safariURL) {
                        UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: view.window)
        
        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            let deltaY = touchPoint.y - initialTouchPoint.y
            
            if deltaY > 0 {
                view.frame.origin.y = deltaY
            }
        case .ended, .cancelled:
            let deltaY = touchPoint.y - initialTouchPoint.y
            
            if deltaY > dismissThreshold {
                dismiss(animated: true, completion: nil)
            } else {
                // Reset the view position
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = 0
                }
            }
        default:
            break
        }
    }
    
    //close the view
    @IBAction func closeDetailView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func updateData(with locationForecast: LocationForecastResponse) {
        
        mapLocationName?.text = "\(locationForecast.location.name) \(locationForecast.location.postcode)"
        
        mapLocationRainfall.text = "\(locationForecast.forecasts.rainfall.days.first?.entries.first?.probability ?? 0)%"
        
        //fetch the temp
        if let firstDay = locationForecast.forecasts.weather.days.first,
           let firstEntry = firstDay.entries.first {
            let minTemperature = firstEntry.min
            let maxTemperature = firstEntry.max
            
            mapLocationLowTemp.text = "\(minTemperature)°"
            mapLocationHighTemp.text = "\(maxTemperature)°"
        } else {
            mapLocationLowTemp.text = "N/A"
            mapLocationHighTemp.text = "N/A"
        }
        
        //fetch the precis
        if let firstDay = locationForecast.forecasts.precis.days.first {
            let entries = firstDay.entries
            var precisCounts: [String: Int] = [:]
            
            //count the occurrences of each precis value
            for entry in entries {
                let precis = entry.precis
                precisCounts[precis] = (precisCounts[precis] ?? 0) + 1
            }
            
            //find average
            var mostFrequentPrecis = ""
            var highestCount = 0
            for (precis, count) in precisCounts {
                if count > highestCount {
                    mostFrequentPrecis = precis
                    highestCount = count
                }
            }
            
            mapLocationPrecis.text = mostFrequentPrecis
        } else {
            mapLocationPrecis.text = "N/A"
        }
        
        //fetch the wind
        if let firstDay = locationForecast.forecasts.wind.days.first {
            let entries = firstDay.entries
            
            //calculate average wind speed
            let totalSpeed = entries.reduce(0.0) { $0 + $1.speed }
            let averageSpeed = totalSpeed / Double(entries.count)
            
            //format the average speed with one decimal point
            let formattedSpeed = String(format: "%.1f", averageSpeed)
            
            mapLocationWind.text = "\(formattedSpeed) km/h"
            
        } else {
            mapLocationWind.text = "N/A" }
        
        
        if let userLocation = userLocation {
            fetchDistanceAndDuration(from: userLocation, to: locationForecast.location) { distanceText, durationText in
                DispatchQueue.main.async {
                    //UI updates for distance and duration
                    let formattedDurationText = self.formatDurationText(durationText)
                    self.mapLocationHours.text = formattedDurationText
                    self.mapLocationKlms.text = distanceText
                    print("Distance data: \(distanceText), Duration data: \(formattedDurationText)")
                }
            }
        }
    }
    
    //change text format
    func formatDurationText(_ durationText: String) -> String {
        var formattedText = durationText
        
        //format change
        formattedText = formattedText.replacingOccurrences(of: " hours", with: "hr")
        formattedText = formattedText.replacingOccurrences(of: " mins", with: "m")
        
        return formattedText
    }
    
    func fetchDistanceAndDuration(from origin: CLLocation, to destination: Location, completion: @escaping (String, String) -> Void) {

        print("Fetching distance and duration data...")
        
        let apiKey = "AIzaSyDZNlu3kX7Cv9cyJXX1o_36OZXvj8UkMqk"
        let baseURL = "https://maps.googleapis.com/maps/api/distancematrix/json"
        
        let originString = "\(origin.coordinate.latitude),\(origin.coordinate.longitude)"
        let destinationString = "\(destination.lat),\(destination.lng)"
        
        let urlString = "\(baseURL)?origins=\(originString)&destinations=\(destinationString)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching distance data: \(error)")
                return
            }
            
            guard let data = data else {
                print("Invalid data received from Distance Matrix API")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GoogleDistanceMatrixResponse.self, from: data)
                if let element = response.rows.first?.elements.first {
                    if let distanceText = element.distance?.text, let durationText = element.duration?.text {
                        // Call the completion block with fetched data
                        completion(distanceText, durationText)
                    }
                }
            } catch {
                print("Error decoding distance data: \(error)")
            }
        }
        
        task.resume()
    }
}
