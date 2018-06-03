//
//  SearchViewController.swift
//  PatriotiskSelskabMobile
//
//  Created by Elitsa Marinovska on 22.05.18.
//  Copyright © 2018 Elitsa Marinovska. All rights reserved.
//

import UIKit
import DropDown

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var passedTrialType:String = ""
    var passedCrop:String = ""
    var passedYear:String = ""
    var passedYears:[[String: Any]] = []
    var trialGroups = [Int:[String:Any]]()
    var chemicals:[[String: Any]] = []
    var selectedTrialType:Int = 0
    var selectedCrop:Int = 0
    var selectedYear:String = ""
    let trialTypeDropDown = DropDown()
    let cropDropDown = DropDown()
    let yearDropDown = DropDown()
    var trialtypes:[[String: Any]] = []
    var crops:[[String: Any]] = []
    var years:[[String:Any]] = []
    
    @IBOutlet weak var trialTypeLabel: UILabel!
    @IBOutlet weak var cropLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var selectTrialType: UIButton!
    @IBOutlet weak var selectCrop: UIButton!
    @IBOutlet weak var selectYear: UIButton!
    
    @IBOutlet weak var chemicalsCollection: UICollectionView!
    
    @IBAction func searchBtn(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var vc:Any
        vc = sb.instantiateViewController(withIdentifier: "SearchChemicalView") as! SearchViewController
        (vc as! SearchViewController).passedTrialType = self.trialTypeLabel.text!
        (vc as! SearchViewController).passedCrop = self.cropLabel.text!
        (vc as! SearchViewController).passedYears = self.years
        (vc as! SearchViewController).passedYear = self.selectedYear
        (vc as! SearchViewController).trialtypes = self.trialtypes
        (vc as! SearchViewController).crops = self.crops
        (vc as! SearchViewController).years = self.years
        self.present(vc as! UIViewController, animated: true, completion: nil)
    }
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
            yearDropDown.dataSource.append((year["Year"] as! NSNumber).stringValue)
        }
        self.years.sort(by:{($0["Year"] as! NSNumber).stringValue > ($1["Year"] as! NSNumber).stringValue})
        yearDropDown.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chemicalsCollection.delegate = self
        chemicalsCollection.dataSource = self
        
        self.trialTypeLabel.text = passedTrialType
        self.cropLabel.text = passedCrop
        self.yearLabel.text = passedYear
        
        trialTypeDropDown.anchorView = selectTrialType
        cropDropDown.anchorView = selectCrop
        yearDropDown.anchorView = selectYear
        
        self.getTrialGroups()
        
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
                            if(self.years.contains(where: { ($0["Year"] as! NSNumber).stringValue == (object["Year"] as! NSNumber).stringValue}) == false)
                            {
                                self.years.append(object)
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
                if(item == (year["Year"] as! NSNumber).stringValue)
                {
                    self.selectedYear = (year["Year"] as! NSNumber).stringValue
                }
            }
            self.yearLabel.text = item
        }
    }

    
    func getTrialGroups() {
        
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for object in array {
                    var added = false
                    if((object["TrialTypeName"] as! String) == self.passedTrialType && (object["CropName"] as! String) == self.passedCrop && added == false)
                    {
                        self.trialGroups[(object["TrialGroupID"] as! NSNumber).intValue] = object
                        added = true
                    }
                }
            }
            self.getTreatments()
        }
        self.getData(url:"http://localhost:8000/client/data/TrialGroups.json", myCompletionHandler: myCompHand)
    }
    
    func getTreatments() {
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            
            var newTrialGroup = [String: Any]()
            var similarTrGroups = [Int:[String: Any]]()
            
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for trialGroup in self.trialGroups.values {
                    var added = false
                    newTrialGroup = trialGroup
                    var treatments = [[String:Any]]()
                    for object in array {
                        if((object["TrialGroupID"] as! NSNumber).intValue == (newTrialGroup["TrialGroupID"] as! NSNumber).intValue)
                        {
                            treatments.append(object)
                        }
                    }
                    newTrialGroup["Treatments"] = treatments
                    
                    for treatment in treatments{
                        if(treatment["DoseLog"] as! Bool == true && added == false){
                            similarTrGroups[(newTrialGroup["TrialGroupID"] as! NSNumber).intValue] = newTrialGroup
                            
                            var chemical = [String:Any]()
                            chemical["TrialGroupID"] = (newTrialGroup["TrialGroupID"] as! NSNumber).intValue
                            chemical["ProductName"] = treatment["ProductName"] as! String
                            self.chemicals.append(chemical)
                            added = true
                        }
                    }
                }
            }
            self.trialGroups = similarTrGroups
        }
        self.getData(url:"http://localhost:8000/client/data/Treatments.json", myCompletionHandler: myCompHand)
    }
    func getData(url: String, myCompletionHandler: Any?){
        let urlString = url
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: myCompletionHandler as! (Data?, URLResponse?, Error?) -> Void).resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chemicals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chemicalsCollection.dequeueReusableCell(withReuseIdentifier: "chemicalCell", for: indexPath) as! TopResultCollectionViewCell
        cell.trialTypeLbl.text = self.chemicals[indexPath.row]["ProductName"] as? String
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chemicalSegue" {
        let trialNumber = chemicals[(chemicalsCollection.indexPath(for: (sender as! UICollectionViewCell))?.row)!]["TrialGroupID"] as! Int
        (segue.destination as! TrialGroupViewController).passedTrialGrObj = self.trialGroups[trialNumber]!
        (segue.destination as! TrialGroupViewController).selectedGroupsArray = [[String:Any]]()
        (segue.destination as! TrialGroupViewController).isChemical = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didUnwindToChemicalsView(_ sender: UIStoryboardSegue){
    }
}
