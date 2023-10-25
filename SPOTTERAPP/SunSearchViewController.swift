//
//  SunSearchViewController.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 6/6/2023.
//

import UIKit
import DropDown

class SunSearchViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var searchSunButton: UIButton!
    @IBOutlet weak var subscriptionButton: UIButton!
    
    let dropDown = DropDown()
    var selectedDropDownItem: String?
    
    var willyWeatherAPI: WillyWeatherAPI? //create an instance of WillyWeatherAPI
    
    var filteredLocations: (names: [String], locationForecasts: [LocationForecastResponse])?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        willyWeatherAPI = WillyWeatherAPI()
        
        //set the min date for the date picker
        let calendar = Calendar.current
        let minDate = calendar.startOfDay(for: Date())
        
        //set the max date for the date picker
        let maxDate = calendar.date(byAdding: .day, value: 6, to: minDate)
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        //change the text color of the date picker
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
        datePicker.setValue(attributes, forKey: "textColor")
        
        datePicker.contentHorizontalAlignment = .center
        datePicker.backgroundColor = .darkGray
        
        //configure dropdown items
        dropDown.dataSource = ["All Of NSW", "South Coast", "Central Coast", "North Coast"]
        
        //setup dropdown selection handling
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.handleDropDownSelection(index: index, item: item)
            
            self?.selectedDropDownItem = item
            self?.dropDownButton.setTitle(item, for: .normal)
        }
        
        searchSunButton.addTarget(self, action: #selector(searchSunButtonTapped), for: .touchUpInside)
    }
    
    @IBAction func searchSunButtonTapped(_ sender: UIButton) {
        
        //get selected date from the date picker
        let selectedDate = datePicker.date
        
        //get selected area from the pull-down menu
        let selectedArea = dropDown.selectedItem ?? ""
        
        //check if the willyWeatherAPI instance is not nil
        if let api = willyWeatherAPI {
            
            //call the setLocation and setDate methods of WillyWeatherAPI
            switch selectedArea {
            case "All Of NSW":
                api.setLocation(location: 3)
            case "South Coast":
                api.setLocation(location: 2)
            case "Central Coast":
                api.setLocation(location: 1)
            case "North Coast":
                api.setLocation(location: 0)
            default:
                
                break
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let formattedDate = dateFormatter.string(from: selectedDate)
            api.setDate(date: formattedDate)
            
            
            //use the fetchData method of WillyWeatherAPI to retrieve the data
            api.fetchData { locationForecasts in
                DispatchQueue.main.async {
                    //filter the location forecasts based on rainfall probability <= 5%
                    let filteredForecasts = locationForecasts.filter { forecast in
                        if let firstDay = forecast.forecasts.rainfall.days.first,
                           let firstEntry = firstDay.entries.first {
                            let rainfallProbability = firstEntry.probability
                            return rainfallProbability <= 5
                        }
                        return false
                    }
                    
                    
                    if filteredForecasts.isEmpty {
                        //show a popup message when there are no sunny areas
                        let alertController = UIAlertController(title: "NO SUN!",
                                                                message: "There are no sunny areas for your selection. Please choose again",
                                                                preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let names = filteredForecasts.compactMap { $0.location.name }
                        
                        //instantiate the SunnyListViewController and present it
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let sunnyList = storyboard.instantiateViewController(withIdentifier: "SunnyListViewController") as? SunnyListViewController {
                            sunnyList.selectedArea = selectedArea
                            sunnyList.selectedDate = selectedDate
                            sunnyList.locationNames = names
                            sunnyList.locationForecast = filteredForecasts
                            
                            //present SunnyListViewController modally
                            self.present(sunnyList, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }

         
    @IBAction func dropDownButtonTapped(_ sender: Any) {
        if let selected = selectedDropDownItem {
            dropDownButton.setTitle(selected, for: .normal)
        }
        dropDown.show()
    }
    
    //method to handle the dropdown item selection
    func handleDropDownSelection(index: Int, item: String) {
        switch index {
        case 0:
            //handle selection for Item 1
            print("All Of NSW selected")
        case 1:
            //handle selection for Item 2
            print("South Coast selected")
        case 2:
            //handle selection for Item 3
            print("Central Coast selected")
        case 3:
            //handle selection for Item 4
            print("North Coast selected")
        default:
            
            break
        }
    }
    
    @IBAction func subscriptionButtonTapped(_ sender: Any) {
       
    //please note this is a dummy url and will be invalid - scenario purposes only
        let appStoreURL = URL(string: "https://apps.apple.com/app/spotter-app")!

        if UIApplication.shared.canOpenURL(appStoreURL) {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
               }
           }
    
}

