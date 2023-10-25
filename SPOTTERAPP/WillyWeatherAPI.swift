//
//  WillyWeatherAPI.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 9/6/2023.
//

import Foundation

class WillyWeatherAPI {
    
    var locationForecast: [LocationForecastResponse]? //add location forecast property
    
    struct Location {
        let name: String
        let id: Int
        //var rainfallProbability: Double?
    }
    
    //WillyWeatherAPI Key
    private let apiKey = "MDc0YWU5ZmIyNDNmNGNlMWJhNGRkZD"
    
    var northLocations: [Location]
    var centralLocations: [Location]
    var southLocations: [Location]
    var userSelectedLocation: [Location]?
    //var userSelectedSwellSize: [Swell]
    var userSelectedDate: String?
    var allLocations: [Location] = [] // used for the initial map view
    
    //chosen locations - I had a limit with locations with my API otherwise it would cost me money
    init() {
        self.centralLocations = []
        self.centralLocations.append(Location(name: "Sydney", id: 4950))
        self.centralLocations.append(Location(name: "Gosford", id: 2370))
        self.centralLocations.append(Location(name: "The Entrance", id: 2440))
        self.centralLocations.append(Location(name: "Charlestown", id: 2972))
        self.centralLocations.append(Location(name: "Newcastle", id: 2919))
        
        self.northLocations = []
        self.northLocations.append(Location(name: "Nelson Bay", id: 2914))
        self.northLocations.append(Location(name: "Forster", id: 2706))
        self.northLocations.append(Location(name: "Port Macquarie", id: 4260))
        self.northLocations.append(Location(name: "Crescent Head", id: 3769))
        self.northLocations.append(Location(name: "Coffs Harbour", id: 3737))
        self.northLocations.append(Location(name: "Yamba", id: 4600))
        self.northLocations.append(Location(name: "Ballina", id: 3555))
        self.northLocations.append(Location(name: "Byron", id: 3690))
        self.northLocations.append(Location(name: "Kingscliff", id: 4974))
        
        self.southLocations = []
        self.southLocations.append(Location(name: "Wollongong", id: 3272))
        self.southLocations.append(Location(name: "Nowra", id: 1839))
        self.southLocations.append(Location(name: "Huskisson", id: 1929))
        self.southLocations.append(Location(name: "Batemans Bay", id: 1215))
        self.southLocations.append(Location(name: "Moruya", id: 1760))
        self.southLocations.append(Location(name: "Bermagui", id: 1812))
        self.southLocations.append(Location(name: "Tathra", id: 1225))
        self.southLocations.append(Location(name: "Merimbula", id: 1716))
        self.southLocations.append(Location(name: "Green Cape", id: 1489))
        
        self.allLocations += self.centralLocations
        self.allLocations += self.northLocations
        self.allLocations += self.southLocations
    }
    
    //function to fetch the weather forecast once the location id has been obtained
    // takes locationId as input and returns a json object
    
    //FOR THE SEARCHING
    func fetchLocationForecasts(locationId: Int, completionHandler: @escaping (LocationForecastResponse?) -> Void) {
        
        //API request url
        let url = "https://api.willyweather.com.au/v2/\(apiKey)/locations/\(locationId)/weather.json?forecasts=rainfall,weather,wind,precis,swell,tides&days=1&startDate=\(userSelectedDate ?? "")"
        
        //debugging
        //print("API Request URl", url)
        
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completionHandler(nil)
                return
            }
            
            //print the received JSON data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON Response:", jsonString)
            }
            
            do {
                
                
                let decoder = JSONDecoder()
                let locationForecast = try decoder.decode(LocationForecastResponse.self, from: data)
                
                //debugging
                //                print("Received locationForecast:", locationForecast)
                //                print("Received JSON Response:", String(data: data, encoding: .utf8) ?? "")
                //                print("Location Name:", locationForecast.location.name)
                //                print("Location ID:", locationForecast.location.id)
                //                print("Rainfall Days:", locationForecast.forecasts.rainfall.days)
                
                
                completionHandler(locationForecast) // return a single instance of our struct
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
                //new code
                completionHandler(nil)
            }
        }
        task.resume()
    }
    
    
    //FOR THE HOME PAGE
    func fetchLocationHP(for date: String, at locationId: Int, completionHandler: @escaping (LocationForecastResponse?) -> Void) {

        let url = "https://api.willyweather.com.au/v2/\(apiKey)/locations/\(locationId)/weather.json?forecasts=rainfall,weather,wind,precis,swell,tides&days=1&startDate=\(date)"
        
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completionHandler(nil)
                return
            }
            
//            // Print the received JSON data - debug
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Received JSON Response:", jsonString)
//            }
            
            do {
                
                
                let decoder = JSONDecoder()
                let locationForecast = try decoder.decode(LocationForecastResponse.self, from: data)
                
                //debugging
                //                print("Received locationForecast:", locationForecast)
                //                print("Received JSON Response:", String(data: data, encoding: .utf8) ?? "")
                //                print("Location Name:", locationForecast.location.name)
                //                print("Location ID:", locationForecast.location.id)
                //                print("Rainfall Days:", locationForecast.forecasts.rainfall.days)
                
                
                completionHandler(locationForecast) // return a single instance of our struct
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
                //new code
                completionHandler(nil)
            }
        }
        task.resume()
    }
    
    //helper function to get the current date in the required format
    private func currentDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
    
    
    func setLocation(location: Int) {
        
        switch location {
        case 0:
            self.userSelectedLocation = self.northLocations
            print("North Coast selected")
        case 1:
            self.userSelectedLocation = self.centralLocations
            print("Central selected")
        case 2:
            self.userSelectedLocation = self.southLocations
            print("South Coast selected")
        case 3:
            self.userSelectedLocation = self.southLocations + self.centralLocations + self.northLocations
            print("All locations selected")
        default:
            
            break
        }
    }
    
    func addLocation(name: String, id: Int) {
        let newLocation = Location(name: name, id: id)
        self.allLocations.append(newLocation)
    }
    
    
    func setDate(date: String) {
        self.userSelectedDate = date
    }
    
    
    //testing this new code
    func fetchData(completionHandler: @escaping ([LocationForecastResponse]) -> Void) {
        var locationForecasts: [LocationForecastResponse] = []
        let group = DispatchGroup()
        
        if let userSelectedDate = self.userSelectedDate, let userSelectedLocation = self.userSelectedLocation {
            //use the existing API call for SunSearchViewController
            let locationIds = userSelectedLocation.map { $0.id }
            
            for locationId in locationIds {
                group.enter()
                fetchLocationForecasts(locationId: locationId) { response in
                    if let forecast = response {
                        locationForecasts.append(forecast)
                    }
                    group.leave()
                }
            }
        } else {
            //use the new API call for the homepage scenario
            let locationIds = allLocations.map { $0.id }
            
            for locationId in locationIds {
                group.enter()
                fetchLocationHP(for: currentDate(), at: locationId) { response in
                    if let forecast = response {
                        locationForecasts.append(forecast)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.locationForecast = locationForecasts
            //print("Location Forecasts Count:", locationForecasts.count) DEBUG
            completionHandler(locationForecasts)
        }
    }
}

