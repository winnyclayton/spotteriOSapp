//
//  SunnyListViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 23/6/2023.
//


import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class SunnyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tblTableView: UITableView!
    
    var locationNames: [String] = []
    var locationIds: [Int] = []
    var locationForecast: [LocationForecastResponse] = []
    var locationManager: CLLocationManager?
    
    var didUpdateUserLocation = false
    
    var selectedLocationForecast: LocationForecastResponse? //store the selected location forecast for directions icon
    
    var selectedDate: Date?
    var selectedArea: String?
    
    //dictionaries to store data for klms and hours
    var distanceData: [String: String] = [:]
    var durationData: [String: String] = [:]
    
    var SelectedIndex = -1
    var isCollapsed = false
    
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    var userLocation: CLLocation? //store the users current location here
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        willyWeatherAPI = WillyWeatherAPI()
        
        //request user location
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        tblTableView.estimatedRowHeight = 235
        tblTableView.rowHeight = UITableView.automaticDimension
        
        tblTableView.dataSource = self
        tblTableView.delegate = self
        tblTableView.reloadData()
        
    }
    
    @objc private func handleSunnyListDirectionsTap(_ sender: UITapGestureRecognizer) {
        print("handleSunnyListDirectionsTap called")
        
        if let userLocation = userLocation, let destination = selectedLocationForecast?.location {
            print("User Location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
            print("Destination: lat=\(destination.lat), lng=\(destination.lng)")
            
            if let tappedRowIndex = sender.view?.tag {
                print("Tapped Row Index: \(tappedRowIndex)")
                
                let indexPath = IndexPath(row: tappedRowIndex, section: 0)
                print("IndexPath: \(indexPath)")
                
                print("sunnyListDirections tapped for cell at index: \(tappedRowIndex)")
                
                //open google maps using stored data
                let googleMapsURL = "comgooglemaps://?saddr=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&daddr=\(destination.lat),\(destination.lng)&directionsmode=driving"
                
                print("Google Maps URL: \(googleMapsURL)")
                
                if let url = URL(string: googleMapsURL) {
                    //check if google maps app is installed
                    if UIApplication.shared.canOpenURL(url) {
                        print("Google Maps app can be opened")
                        
                        //open the google maps app
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("Google Maps app not installed")
                        //google maps app not installed, open in Safari
                        let safariURL = "https://www.google.com/maps/dir/?api=1&origin=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&destination=\(destination.lat),\(destination.lng)&travelmode=driving"
                        if let safariURL = URL(string: safariURL) {
                            UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        } else {
            print("User location or destination is nil")
        }
    }
    
    
    @IBAction func doneWithListTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Do any additional setup after loading the view.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.SelectedIndex == indexPath.row && isCollapsed == true
        {
            return 235
        }else{
            return 112
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationNames.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SunnyListTableViewCell") as! SunnyListTableViewCell
        
        //fetch data
        guard indexPath.row < locationForecast.count else {
            // show a loading state or a placeholder here.
            return cell
        }
        
        let locationForecast = self.locationForecast[indexPath.row]
        let locationName = locationNames[indexPath.row]
        //let locationId = locationIds[indexPath.row]
        
        //name data
        cell.lblName.text = locationName + " NSW " + locationForecast.location.postcode
        
        //fetch rainfall
        if !locationForecast.forecasts.rainfall.days.isEmpty {
            
            let firstDay = locationForecast.forecasts.rainfall.days[0]
            if !firstDay.entries.isEmpty {
                let firstEntry = firstDay.entries[0]
                let rainfallProbability = firstEntry.probability
                cell.lblRainfall.text = "\(rainfallProbability)%"
            } else {
                cell.lblRainfall.text = "db1"
            }
        } else {
            cell.lblRainfall.text = "db2"
        }
        
        
        //fetch temp
        if let firstDay = locationForecast.forecasts.weather.days.first,
           let firstEntry = firstDay.entries.first {
            let minTemperature = firstEntry.min
            let maxTemperature = firstEntry.max
            
            cell.lblLowTemp.text = "\(minTemperature)°"
            cell.lblHighTemp.text = " \(maxTemperature)°"
        } else {
            cell.lblLowTemp.text = "N/A"
            cell.lblHighTemp.text = "N/A"
        }
        
        //fetch precis
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
            
            cell.lblPrecis.text = mostFrequentPrecis
        } else {
            cell.lblPrecis.text = "N/A"
        }
        
        
        //fetch wind
        if let firstDay = locationForecast.forecasts.wind.days.first {
            let entries = firstDay.entries
            
            //calculate average wind speed
            let totalSpeed = entries.reduce(0.0) { $0 + $1.speed }
            let averageSpeed = totalSpeed / Double(entries.count)
            
            //format the average speed with one decimal point
            let formattedSpeed = String(format: "%.1f", averageSpeed)
            
            cell.lblWind.text = "\(formattedSpeed) km/h"
        } else {
            cell.lblWind.text = "N/A"
        }
        
        //new code to update data with stored data
        if let distance = distanceData[String(indexPath.row)], let duration = durationData[String(indexPath.row)] {
            cell.lblKlms.text = distance
            cell.lblHours.text = duration
        } else {
            cell.lblKlms.text = "N/A"
            cell.lblHours.text = "N/A"
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSunnyListDirectionsTap(_:)))
        cell.sunnyListDirections.isUserInteractionEnabled = true
        cell.sunnyListDirections.tag = indexPath.row //tag the image view with the cell's row index
        
        if SelectedIndex == indexPath.row && isCollapsed == true {
            cell.sunnyListDirections.addGestureRecognizer(tapGesture)
        } else {
            //remove the gesture recognizer if the cell is not expanded
            cell.sunnyListDirections.gestureRecognizers?.forEach { cell.sunnyListDirections.removeGestureRecognizer($0) }
        }
        
        return cell
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get the users current location
        guard let userLocation = locations.first, !didUpdateUserLocation else { return }
        
        didUpdateUserLocation = true
        
        self.userLocation = userLocation //store the user location
        
        print("User Location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
        
        var destinations: [CLLocationCoordinate2D] = []
        for locationForecast in locationForecast {
            let destination = CLLocationCoordinate2D(latitude: CLLocationDegrees(locationForecast.location.lat), longitude: CLLocationDegrees(locationForecast.location.lng))
            destinations.append(destination)
        }
        
        fetchDistanceMatrix(origin: userLocation.coordinate, destinations: destinations) { (distanceData, durationData, error) in
            if let distanceData = distanceData, let durationData = durationData {
                DispatchQueue.main.async {
                    //update the corresponding labels in the table view cell
                    for (index, distance) in distanceData {
                        let duration = durationData[index]
                        let indexPath = IndexPath(row: Int(index)!, section: 0)
                        if let cell = self.tblTableView.cellForRow(at: indexPath) as? SunnyListTableViewCell {
                            cell.lblKlms.text = distance
                            cell.lblHours.text = duration
                        }
                    }
                }
            } else {
                print("Error fetching distance matrix: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedLocationForecast = locationForecast[indexPath.row]
        
        if SelectedIndex == indexPath.row {
            if isCollapsed == false {
                isCollapsed = true
            } else {
                isCollapsed = false
            }
        } else {
            isCollapsed = true
        }
        
        self.SelectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    
    //rotate the expand icon
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let sunnyCell = cell as? SunnyListTableViewCell else {
            return
        }
        
        if SelectedIndex == indexPath.row && isCollapsed == true {
            sunnyCell.rotateExpandIcon()
        } else {
            sunnyCell.resetExpandIcon()
        }
    }
    
    //change text format
    func formatDurationText(_ durationText: String) -> String {
        var formattedText = durationText
        
        //format changes
        formattedText = formattedText.replacingOccurrences(of: " hour", with: "hr")
        formattedText = formattedText.replacingOccurrences(of: " mins", with: "m")
        
        return formattedText
    }
    
    func fetchDistanceMatrix(origin: CLLocationCoordinate2D, destinations: [CLLocationCoordinate2D], completion: @escaping ([String: String]?, [String: String]?, Error?) -> Void) {
        //Google Maps Distance Matrix API endpoint
        let apiKey = "AIzaSyDZNlu3kX7Cv9cyJXX1o_36OZXvj8UkMqk"
        let baseURL = "https://maps.googleapis.com/maps/api/distancematrix/json"
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationsString = destinations.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        let encodedOrigin = originString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedDestinations = destinationsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?origins=\(encodedOrigin)&destinations=\(encodedDestinations)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, nil, NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil, NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data received from Distance Matrix API"]))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = json["status"] as? String, status == "OK",
                       let rows = json["rows"] as? [[String: Any]],
                       let elements = rows.first?["elements"] as? [[String: Any]] {
                        
                        for (index, element) in elements.enumerated() {
                            if let status = element["status"] as? String, status == "OK",
                               let distance = element["distance"] as? [String: Any],
                               let distanceText = distance["text"] as? String,
                               let duration = element["duration"] as? [String: Any],
                               let durationText = duration["text"] as? String {
                                self.distanceData[String(index)] = distanceText
                                let formattedDurationText = self.formatDurationText(durationText)
                                self.durationData[String(index)] = formattedDurationText
                            }
                        }
                        
                        DispatchQueue.main.async {
                            completion(self.distanceData, self.durationData, nil)
                        }
                        
                        return
                    }
                }
                
                completion(nil, nil, NSError(domain: "com.example.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from Distance Matrix API"]))
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSunnyResultsOnMap" {
            if let sunnyMap = segue.destination as? SunResultsViewController {
                let data = (locationNames: locationNames, locationForecasts: locationForecast)
                sunnyMap.selectedDate = selectedDate
                sunnyMap.selectedArea = selectedArea
                sunnyMap.dataToDisplay = data
                
            }
        }
    }
}
    
