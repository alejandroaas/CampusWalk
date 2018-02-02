//
//  CampusMapModel.swift
//  CampusWalk
//
//  Created by Alejandro Andrade on 10/16/17.
//  Copyright © 2017 Alejandro Andrade. All rights reserved.
//

import Foundation
import MapKit

struct Building {
    let name : String
    let code : Int
    let yearConstructed : Int
    let latitude : Double
    let longitude : Double
    let photoName : String
    var detail : String
}

struct BuildingKeys{
    static let name = "name"
    static let code = "opp_bldg_code"
    static let lat = "latitude"
    static let long = "longitude"
    static let photo = "photo"
    static let year = "year_constructed"
}

typealias BuildingData = [String:[Building]]


class CampusMapModel{
    static let sharedInstance = CampusMapModel()
    let initialLocation = CLLocation(latitude: 40.8000498263108, longitude: -77.8592396273773)
    fileprivate var building  : [Building]
    fileprivate var buildings : BuildingData
    fileprivate let buildingKeys : [String]
    fileprivate var searchBuilding = [Building]()
    static var rowHeight = CGFloat(0)
    private init(){
        var _building = [Building]()
        var _buildings = BuildingData()
        let path = Bundle.main.path(forResource: "buildings", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!) as! [[String : Any]]
        for building in dataArray{
            let __building = Building(name: building[BuildingKeys.name] as! String, code: building[BuildingKeys.code] as! Int, yearConstructed: building[BuildingKeys.year] as! Int, latitude: building[BuildingKeys.lat] as! Double, longitude: building[BuildingKeys.long] as! Double, photoName: building[BuildingKeys.photo] as! String, detail: "Detail Building Here")
            _building.append(__building)
            let firstLetter = __building.name.firstLetter()!
            
            if _buildings[firstLetter]?.append(__building) == nil {
                _buildings[firstLetter] = [__building]
            }
        
        }
        //_building.sort(by: { (lhs:Building, rhs:Building)->Bool in return lhs.name < rhs.name})
        building = _building
        buildings = _buildings
        buildingKeys = Array(buildings.keys).sorted()
        
    }
    var sectionIndexTitles : [String] {get {return buildingKeys}}
    func titleFor(section:Int) -> String {
        return buildingKeys[section]
    }
    func buildingFor(indexPath:IndexPath)-> Building{
        let key = buildingKeys[indexPath.section]
        let buildingArray = buildings[key]!
        return buildingArray[indexPath.row]
    }
    var sectionCount : Int {get {return buildingKeys.count }}
    func rowCount(section : Int) -> Int {
        let key = buildingKeys[section]
        return (buildings[key]?.count)!
    }
    
    func searchBuildingForName(searchText : String){
        var _searchBuilding = [Building]()
        for building in building{
            if(building.name.lowercased().contains(searchText.lowercased())){
                _searchBuilding.append(building)
            }
        }
        searchBuilding.removeAll()
        searchBuilding = _searchBuilding
    }
    
    func searchBuildingForYear(searchText : String){
        var _searchBuilding = [Building]()
        for building in building{
            if(String(building.yearConstructed).contains(searchText.lowercased())){
                _searchBuilding.append(building)
            }
        }
        searchBuilding.removeAll()
        searchBuilding = _searchBuilding
    }
    
    func buildingForSearch(indexPath: IndexPath) -> Building {
        return searchBuilding[indexPath.row]
    }
    func searchBuildingCount() -> Int {
        return searchBuilding.count
    }
    
    
    
    func detailFor(name:String, detail: String) {

        for i in 1..<building.count{
            if building[i].name == name{
                if detail == "" {
                    building[i].detail = "Detail Building Here"
                    break
                }else{
                building[i].detail = detail
                break
                }
            }
        }
        for (key,bldg) in buildings{
            for i in 0..<bldg.count{
                if buildings[key]?[i].name == name{
                    if detail == ""{
                        buildings[key]?[i].detail = "Detail Building Here"
                        break
                    }
                    else{
                        buildings[key]?[i].detail = detail
                        break
                    }
                    
                }
            }
        }
    }

}
