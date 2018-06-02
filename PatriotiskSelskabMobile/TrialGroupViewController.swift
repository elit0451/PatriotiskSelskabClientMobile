//
//  TrialGroupViewController.swift
//  PatriotiskSelskabMobile
//
//  Created by Elitsa Marinovska on 22.05.18.
//  Copyright © 2018 Elitsa Marinovska. All rights reserved.
//

import UIKit

extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
}

class TrialGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var passedTrialGrObj = [String: Any]()
    var similarTrialGroups = [Int:[String: Any]]()
    var logChemName = [String]()
    var logChemDosages = [Decimal]()
    var frameHeight:CGFloat = 1176
    
    @IBOutlet weak var trialGroupTop: UILabel!
    @IBOutlet weak var cropNameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stageView: UIView!
    @IBOutlet weak var chemicalView: UIView!
    @IBOutlet weak var treatmentCommentView: UIView!
    @IBOutlet weak var logChemCollection: UICollectionView!
    @IBOutlet weak var similarCollection: UICollectionView!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSimilarTrialGroups()
        
        logChemCollection.delegate = self
        logChemCollection.dataSource = self
        
        similarCollection.delegate = self
        similarCollection.dataSource = self
        
        
        
        trialGroupTop.text = "Trial Group " + (passedTrialGrObj["TrialGroupNr"] as! NSNumber).stringValue
        
        cropNameLbl.text = passedTrialGrObj["CropName"] as? String
        commentLbl.text = passedTrialGrObj["Comment"] as? String
        
        var frameY:CGFloat = 8
        
        var stages = [[String:Any]]()
        
        var logDosages = [Decimal]()
        var treatments = passedTrialGrObj["Treatments"] as! [[String:Any]]
        for treatment in treatments {
            var found = stages.contains {
                ($0["Id"] as! NSNumber).intValue == (treatment["TreatmentID"] as! NSNumber).intValue
            }
            
            if (found == false) {
                stages.append(["Id":treatment["TreatmentID"],"StageName":treatment["TreatmentStage"], "StageDate":treatment["TreatmentDate"], "StageComment":treatment["Comment"],"Products":[[String:Any]]()])
            }
            var newStages = [[String:Any]]()
            for var stage in stages
            {
                var stageProducts = stage["Products"] as! [[String:Any]]
                if ((stage["Id"] as! NSNumber) == (treatment["TreatmentID"] as! NSNumber)) {
                    var dose:Any
                    if (treatment["DoseLog"] as! Bool == true)
                    {
                        dose = "LOG"
                        logDosages.append((treatment["ProductDose"] as! NSNumber).decimalValue)
                    }
                    else
                    {
                        dose = (treatment["ProductDose"] as! NSNumber).stringValue
                    }
                    found = stageProducts.contains
                        {
                            ($0["ProductName"] as! String) == (treatment["ProductName"] as! String)
                    }
                    
                    if (found == false)
                    {
                        stageProducts.append(["ProductName":treatment["ProductName"],"Dosage":dose])
                    }
                }
                stage["Products"] = stageProducts
                var logDosageTxt = ""
                logDosages.sort(by: { $0 > $1 })
                for logChemDosage in logDosages{
                    
                    logDosageTxt += (logChemDosage as NSNumber).stringValue + " | "
                }
                logDosageTxt.removeLast(2)
                stage["LogChemTxt"] = logDosageTxt + " ml"
                newStages.append(stage)
            }
            stages = newStages;
        }
        
        for stage in stages{
            let stageViewCopy = stageView.copyView()
            stageViewCopy.isHidden = false
            stageViewCopy.frame.origin.x = 0
            stageViewCopy.frame.origin.y = frameY
            (stageViewCopy.subviews[0] as! UILabel).text = "Stage " + (stage["StageName"] as! String)
            if let date = (stage["StageDate"] as? String)
            {
                (stageViewCopy.subviews[1] as! UILabel).text = date
            }
            else
            {
                (stageViewCopy.subviews[1] as! UILabel).text = "N/A"
            }
            scrollView.addSubview(stageViewCopy)
            frameY += stageViewCopy.frame.size.height
            for product in stage["Products"] as! [[String:Any]]
            {
                let chemicalViewCopy = chemicalView.copyView()
                chemicalViewCopy.isHidden = false
                chemicalViewCopy.frame.origin.x = 0
                chemicalViewCopy.frame.origin.y = frameY
                (chemicalViewCopy.subviews[0] as! UILabel).text = (product["ProductName"] as! String)
                
                if (product["Dosage"] as! String) == "LOG"{
                    (chemicalViewCopy.subviews[1] as! UILabel).text = (stage["LogChemTxt"] as! String)
                }
                else{
                    (chemicalViewCopy.subviews[1] as! UILabel).text = (product["Dosage"] as! String)
                }
                scrollView.addSubview(chemicalViewCopy)
                frameY += chemicalViewCopy.frame.size.height
                
            }
            let treatmentCommentViewCopy = treatmentCommentView.copyView()
            treatmentCommentViewCopy.isHidden = false
            treatmentCommentViewCopy.frame.origin.x = 0
            treatmentCommentViewCopy.frame.origin.y = frameY
            (treatmentCommentViewCopy.subviews[1] as! UILabel).text = (stage["StageComment"] as! String)
            scrollView.addSubview(treatmentCommentViewCopy)
            frameY += treatmentCommentViewCopy.frame.size.height
        }
        
        scrollView.contentSize = CGSize(width: 375, height: frameY)
        
        
        for treatment in treatments {
            if (treatment["DoseLog"] as! Bool == true)
            {
                logChemName.append(treatment["ProductName"] as! String)
                logChemDosages.append((treatment["ProductDose"] as! NSNumber).decimalValue)
            }
        }
        
        logChemDosages.sort(by: { $0 < $1 })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.logChemCollection{
        return logChemDosages.count
        }
        var blockRows : Double = Double(similarTrialGroups.count) / Double(5)
        blockRows.round(.up)
        var addHeight =  blockRows * 124
        pageScrollView.contentSize = CGSize(width: 768, height: frameHeight + CGFloat(addHeight))
        
        similarCollection.frame = CGRect(x: similarCollection.frame.origin.x, y: similarCollection.frame.origin.y, width: similarCollection.frame.width, height: CGFloat(addHeight))
        return similarTrialGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.logChemCollection{
            let cell = logChemCollection.dequeueReusableCell(withReuseIdentifier: "logChemCell", for: indexPath) as! TrialCollectionViewCell
            
            cell.chemicalLbl.text = logChemName[indexPath.row]
            cell.doseLbl.text = (logChemDosages[indexPath.row] as NSNumber).stringValue + " ml"
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.init(red: 0.416, green: 0.745, blue: 0.953, alpha: 1).cgColor
            
            return cell
        }
        
         let cell = similarCollection.dequeueReusableCell(withReuseIdentifier: "similarResultsCell", for: indexPath) as! TrialCollectionViewCell
        var similarGroups = Array(self.similarTrialGroups.values)
        
        cell.chemicalLbl.text = ((similarGroups[indexPath.row])["Treatments"] as! [[String:Any]])[0]["ProductName"] as! String
        cell.weedLbl.text = (similarGroups[indexPath.row])["CropName"] as! String
        
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.init(red: 0.416, green: 0.745, blue: 0.953, alpha: 1).cgColor
        
        return cell
    }
    
    func getData(url: String, myCompletionHandler: Any?){
        let urlString = url
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: myCompletionHandler as! (Data?, URLResponse?, Error?) -> Void).resume()
        
    }
    
    func getSimilarTrialGroups() {
        
        let myCompHand:(Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let array = json as? [[String: Any]] {
                for object in array {
                    if((object["TrialTypeName"] as! String) == (self.passedTrialGrObj["TrialTypeName"] as! String) && ((object["TrialGroupID"] as! NSNumber).intValue) != (self.passedTrialGrObj["TrialGroupID"] as! NSNumber).intValue)
                    {
                        self.similarTrialGroups[(object["TrialGroupID"] as! NSNumber).intValue] = object
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
                for trialGroup in self.similarTrialGroups.values {
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
                        if(treatment["ProductName"] as! String == (self.passedTrialGrObj["Treatments"] as! [[String:Any]])[0]["ProductName"] as! String){
                            similarTrGroups[(newTrialGroup["TrialGroupID"] as! NSNumber).intValue] = newTrialGroup
                        }
                    }
                }
            }
            self.similarTrialGroups = similarTrGroups
        }
        self.getData(url:"http://localhost:8000/client/data/Treatments.json", myCompletionHandler: myCompHand)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
