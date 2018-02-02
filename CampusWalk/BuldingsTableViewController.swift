//
//  BuldingsTableViewController.swift
//  CampusWalk
//
//  Created by Alejandro Andrade on 10/16/17.
//  Copyright © 2017 Alejandro Andrade. All rights reserved.
//

import UIKit

protocol BuildingDelegate {
    func didChose(building : Building)
}

class BuldingsTableViewController: UITableViewController, UISearchBarDelegate, UITextViewDelegate {
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var searchBar: UISearchBar!
    @objc var searchBarMode = "Name"
    @objc var searchText = ""
    @objc var rowHeight = CGFloat()
    var searchResults  = [Building]()
    let campusMapModel = CampusMapModel.sharedInstance
    var delegate : BuildingDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        rowHeight = CampusMapModel.rowHeight
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        searchBar.placeholder = searchBarMode
        tableView.rowHeight += rowHeight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch searchText {
        case "":
            return campusMapModel.sectionCount
        default:
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return  tableView.rowHeight + rowHeight
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchText {
        case "":
            return campusMapModel.rowCount(section: section)
        default:
            return campusMapModel.searchBuildingCount()
            
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.didChose(building: campusMapModel.buildingFor(indexPath: indexPath))
        }


    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuildingCell", for: indexPath) as! BuildingTableViewCell
        if searchText == ""{
            let building = campusMapModel.buildingFor(indexPath: indexPath)
            cell.name.text = building.name
            cell.code.text = String(building.code)
            cell.year.text = String(building.yearConstructed)
            let image = UIImage(named: building.photoName)
            cell.photo.image = image
            cell.detail.text = building.detail
            cell.detail.delegate = self
            return cell
        }else{
            let building = campusMapModel.buildingForSearch(indexPath: indexPath)
            cell.name.text = building.name
            cell.code.text = String(building.code)
            cell.year.text = String(building.yearConstructed)
            let image = UIImage(named: building.photoName)
            cell.photo.image = image
            cell.detail.text = building.detail
            cell.detail.delegate = self
            return cell
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return campusMapModel.titleFor(section: section)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return campusMapModel.sectionIndexTitles
    }
    
    
    //MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchBarMode {
        case "Name":
            self.searchText = searchText
            campusMapModel.searchBuildingForName(searchText: self.searchText)
            self.tableView.reloadData()
        case "Year":
            self.searchText = searchText
            campusMapModel.searchBuildingForYear(searchText: self.searchText)
            self.tableView.reloadData()
        default:
            return
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = ""
        self.tableView.reloadData()
        searchBar.endEditing(true)

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }


    //MARK: - Navigation Controller Actions
    
    @IBAction func searchYear(_ sender: Any) {
        searchBarMode = "Year"
        searchBar.placeholder = searchBarMode
        searchBar.keyboardType = .numberPad
    }
    
    @IBAction func searchName(_ sender: Any) {
        searchBarMode = "Name"
        searchBar.placeholder = searchBarMode
        searchBar.keyboardType = .default

    }
    
    //MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Detail Building Here"{
            textView.text = ""
        }else{
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Detail Building Here"
        }else{
            let cell = textView.superview?.superview as! BuildingTableViewCell
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            campusMapModel.detailFor(name: cell.name.text!, detail:textView.text)
            
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        if (textView.contentSize.height > rowHeight){
            rowHeight = textView.contentSize.height - rowHeight
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        if textView.text[textView.text.characters.count - 1] == "\n"{
            tableView.rowHeight += rowHeight
            rowHeight = textView.contentSize.height
            CampusMapModel.rowHeight = rowHeight/2
            textView.endEditing(true)
        }

    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
