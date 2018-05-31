//
//  ViewController.swift
//  PatriotiskSelskabMobile
//
//  Created by Elitsa Marinovska on 21.05.18.
//  Copyright © 2018 Elitsa Marinovska. All rights reserved.
//

import UIKit
import DropDown

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var selectedTrialType:Int = 0
    var selectedCrop:Int = 0
    var selectedYear:String = ""
    let trialTypeDropDown = DropDown()
    let cropDropDown = DropDown()
    let yearDropDown = DropDown()
    var trialtypes:[[String: Any]] = []
    var crops:[[String: Any]] = []
    var years:[String] = []
    var topTypeResults:[[String: Any]] = []
    var topTrialGroups = [Int:[String:Any]]()
    
    @IBOutlet weak var trialTypeLabel: UILabel!
    @IBOutlet weak var cropLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var selectTrialType: UIButton!
    @IBOutlet weak var selectCrop: UIButton!
    @IBOutlet weak var selectYear: UIButton!
    
    @IBOutlet weak var topResultsCollection: UICollectionView!
    
    @IBAction func selectTrialTypeClick(_ sender: Any) {
        trialTypeDropDown.dataSource = []
        for trialType in trialtypes
        {
            trialTypeDropDown.dataSource.append(trialType["TrialTypeName"] as! String)
        }
        self.trialtypes.sort(by: {($0["TrialTypeName"] as! String) < ($1["TrialTypeName"] as! String)})
        trialTypeDropDown.show()
    }
    
    @IBAction func selectCropClick(_ sender: Any) {
        cropDropDown.dataSource = []
        
        for crop in crops
        {
            cropDropDown.dataSource.append(crop["CropName"] as! String)
        }
        self.crops.sort(by:{($0["CropName"] as! String) < ($1["CropName"] as! String)})
        cropDropDown.show()
    }
    
    @IBAction func selectYearClick(_ sender: Any) {
        yearDropDown.dataSource = []
        
        for year in years
        {
            yearDropDown.dataSource.append(year)
        }
        self.years.sort(by: { $0 > $1 })
        yearDropDown.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topResultsCollection.delegate = self
        topResultsCollection.dataSource = self
        
        trialTypeDropDown.anchorView = selectTrialType
        cropDropDown.anchorView = selectCrop
        yearDropDown.anchorView = selectYear
        
        self.trialtypes = []
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for object in array {
                    self.trialtypes.append(object)
                }
            }
            self.trialtypes.sort {($0["TrialTypeName"] as! String) < ($1["TrialTypeName"] as! String)}
        }
        
        self.getData(url:"http://localhost:8000/client/data/TrialTypes.json", myCompletionHandler: myCompHand)
        
        
        self.topTypeResults = []
        let myCompHandTopResults:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for object in array {
                    self.topTypeResults.append(object)
                }
            }
            self.topTypeResults.sort {($0["Type"] as! String) < ($1["Type"] as! String)}
        }
    
        self.getData(url:"http://localhost:8000/client/data/TopTypeResults.json", myCompletionHandler: myCompHandTopResults)
        
        trialTypeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedTrialType = self.trialtypes[index]["TrialTypeID"] as! Int
            
            self.crops = []
            self.years = []
            let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                guard let data = data else { return }
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let array = json as? [[String: Any]] {
                    for object in array {
                        if((object["TrialTypeID"] as! NSNumber).intValue == self.selectedTrialType)
                        {
                            self.crops.append(object)
                        }
                    }
                }
            }
            self.getData(url:"http://localhost:8000/client/data/Crops.json", myCompletionHandler: myCompHand)
            self.trialTypeLabel.text = item
            self.cropLabel.text = "Crop"
            self.yearLabel.text = "Year"
        }
        
        
        cropDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedCrop = self.crops[index]["CropID"] as! Int
            
            self.years = []
            let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                guard let data = data else { return }
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let array = json as? [[String: Any]] {
                    for object in array {
                        if((object["CropID"] as! NSNumber).intValue == self.selectedCrop)
                        {
                            if(self.years.contains((object["Year"] as! NSNumber).stringValue) == false)
                            {
                                self.years.append((object["Year"] as! NSNumber).stringValue)
                            }
                        }
                    }
                }
            }
            self.getData(url:"http://localhost:8000/client/data/Years.json", myCompletionHandler: myCompHand)
            self.cropLabel.text = item
            self.yearLabel.text = "Year"
        }
        
        yearDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            for year in self.years
            {
                if(item == year)
                {
                    self.selectedYear = year
                }
            }
            self.yearLabel.text = item
        }
    }
    
    
    func getData(url: String, myCompletionHandler: Any?){
        let urlString = url
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: myCompletionHandler as! (Data?, URLResponse?, Error?) -> Void).resume()
        
     }
    
    func getTrialGroup(trialGroupID : Int) {
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            var trialGroup = [String:Any]()
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for object in array {
                    if((object["TrialGroupID"] as! NSNumber).intValue == trialGroupID)
                    {
                        trialGroup = object
                    }
                }
            }
            self.getTreatment(trialGroupObj: trialGroup)
        }
        self.getData(url:"http://localhost:8000/client/data/TrialGroups.json", myCompletionHandler: myCompHand)
    }
    
    func getTreatment(trialGroupObj : [String:Any]) {
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            
            var newTrialGroup = trialGroupObj
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                var logChemName = ""
                var logChemDosages = [Decimal]()
                var treatments = [[String:Any]]()
                for object in array {
                    if((object["TrialGroupID"] as! NSNumber).intValue == (newTrialGroup["TrialGroupID"] as! NSNumber).intValue)
                    {
                        treatments.append(object)
                        if (object["DoseLog"] as! Bool == true) {
                            logChemName = object["ProductName"] as! String
                            logChemDosages.append((object["ProductDose"] as! NSNumber).decimalValue)
                        }
                    }
                }
                logChemDosages.sort(by: { $0 > $1 })
                
                newTrialGroup["Treatments"] = treatments
                newTrialGroup["LogChemName"] = logChemName
                newTrialGroup["LogChemDosages"] = logChemDosages
                
            }
            self.topTrialGroups[(newTrialGroup["TrialGroupID"] as! NSNumber).intValue] = newTrialGroup
        }
        self.getData(url:"http://localhost:8000/client/data/Treatments.json", myCompletionHandler: myCompHand)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return topTypeResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = topResultsCollection.dequeueReusableCell(withReuseIdentifier: "topResultCell", for: indexPath) as! TopResultCollectionViewCell
        getTrialGroup(trialGroupID: topTypeResults[indexPath.row]["TopTrial"] as! Int)
        cell.trialTypeLbl.text = topTypeResults[indexPath.row]["Type"] as? String
            return cell
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let trialNumber = topTypeResults[(topResultsCollection.indexPath(for: (sender as! UICollectionViewCell))?.row)!]["TopTrial"] as! Int
        (segue.destination as! TrialGroupViewController).passedTrialGrObj = self.topTrialGroups[trialNumber]!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didUnwindToMainView(_ sender: UIStoryboardSegue){
    }
}

