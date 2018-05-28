//
//  MatrixViewController.swift
//  AZPeerToPeerConectvity
//
//  Created by RAHUL R on 28/05/18.
//  Copyright © 2018 AfrozZaheer. All rights reserved.
//

import UIKit
import AZPeerToPeerConnection
import MultipeerConnectivity

fileprivate let itemsPerRow: CGFloat = 5
let randomSeries:[[Int]] = [[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25],[10, 1,20, 8,13,24,25,22, 6, 4,12,16,11,14, 9, 7, 5, 2,17,21,19,18,23, 3,15],[21,23,22, 8, 9, 1,24, 2, 7,25, 6,13,11, 3,17,10,16,14, 4,18,15,20,19,12, 5],
[ 2, 9,10,14, 1,25,22,19,18,24, 4, 8,12,13, 5, 7, 3,15,21,20,23, 6,16,11,17],
[19, 5,11,21,15, 6,20, 8,24, 1,14, 4,22,18,25,17, 9,12, 2, 3,13,23,10,16, 7],[25,15,12, 6,10, 4,19, 5, 1,21,13,20,24, 8,22,18, 3,14,23,11,16, 9, 7, 2,17],[22,24, 9,11,21, 2,18,15,20,17,10,25, 7,23,16,12, 4, 1, 8, 6, 5,19,14, 3,13],[14, 8,25, 6,17,10,23, 3, 9,15, 2,11,12,18,21, 5,19,22,24, 7,20,16, 1,13, 4],[3, 9,20, 5,10,19,14,15,22,18,11,17,24, 1,23, 2, 4,21,16,12, 6, 8,25,13, 7],[13, 4,16,25,18,15,24, 2,10, 9,23,14,22, 5, 3,19, 1,11,20, 7,12,17,21, 6, 8],[14, 8, 3,12, 1, 7,16,19, 4, 9,18,21,24,23, 5,17,13,10,20, 6,11, 2,22,15,25]]
let sectionInsets = UIEdgeInsets.init(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
class MatrixViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var statusLbl: UILabel!
    @IBOutlet var resultLabel: UILabel!
    var isMyClick:Bool = true
    var completedRows:[Int] = [Int]()
    var completedColoums:[Int] = [Int]()
    var bingoObjectArray: [[BingoObj]] = [[BingoObj]]()
    let connection = P2PServiceHandler.sharedInstance
    var bingoArray :[Int] = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        bingoArray = randomSeries[self.generateRandomDigits(1)]
        connection.delegate = self
        // Do any additional setup after loading the view.
        self.populateBingoNumbers()
    }
    
    func populateBingoNumbers()  {
        for i in 0...Int(itemsPerRow) - 1{
            var elementArray = [BingoObj]()
            for j in 0...Int(itemsPerRow) - 1{
                let idx = (i * Int(itemsPerRow)) + j
                let bingoElem = BingoObj.init(number: bingoArray[idx], indexPath: idx)
                elementArray.append(bingoElem)
            }
            bingoObjectArray.append(elementArray)
        }
    }
    func generateRandomDigits(_ digitNumber: Int) -> Int {
        var number = ""
        for i in 0..<digitNumber {
            var randomNumber = arc4random_uniform(10)
            while randomNumber == 0 && i == 0 {
                randomNumber = arc4random_uniform(10)
            }
            number += "\(randomNumber)"
        }
        return Int(number) ?? 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectedObject(bingoObj: BingoObj){
        if bingoObjectArray[bingoObj.xPos].filter({$0.isSelected == true}).count == Int(itemsPerRow){
            if !completedRows.contains(bingoObj.xPos){
                self.completedRows.append(bingoObj.xPos)
            }
        }
        if bingoObjectArray.map({$0[bingoObj.yPos]}).filter({$0.isSelected == true}).count == Int(itemsPerRow){
            if !completedColoums.contains(bingoObj.yPos){
                self.completedColoums.append(bingoObj.yPos)
            }
            
        }
        self.updateResult()
        let totalCompleted = self.completedColoums.count + self.completedRows.count
        if totalCompleted >= Int(itemsPerRow){
            connection.sendData(data: ["message": "opponent won!!!"])
            self.showAlertWith(heading: "Won", "You Won")
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    func showAlertWith(heading: String,_ message:String) {
        let alert = UIAlertController.init(title: heading, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    func updateResult(){
        let totalCompleted = self.completedColoums.count + self.completedRows.count
        switch totalCompleted {
        case 0:
            resultLabel.textColor = UIColor.white
            resultLabel.text = ""
        case 1:
            resultLabel.textColor = UIColor.green
            resultLabel.text = "B"
        case 2:
            resultLabel.textColor = UIColor.green
            resultLabel.text = "BI"
        case 3:
            resultLabel.textColor = UIColor.green
            resultLabel.text = "BIN"
        case 4:
            resultLabel.textColor = UIColor.green
            resultLabel.text = "BING"
        case 5:
            resultLabel.textColor = UIColor.green
            resultLabel.text = "BINGO"
        default:
            resultLabel.textColor = UIColor.red
            resultLabel.text = "BINGO"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MatrixViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bingoObjectArray.flatMap({$0}).count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatrixCell",
                                                          for: indexPath) as! MatrixViewCell
        let d:Int = Int(indexPath.row / Int(itemsPerRow))
        let r:Int = Int(indexPath.row % Int(itemsPerRow))
        cell.titleLabel?.text = String(bingoObjectArray[d][r].number)
        if (bingoObjectArray[d][r].isMySelection){
            cell.selectionImage.image = UIImage.init(named: "select_myself")
            cell.titleLabel?.textColor = UIColor.black
        }else if (bingoObjectArray[d][r].isSelected){
            cell.selectionImage.image = UIImage.init(named: "select_oppo")
            cell.titleLabel?.textColor = UIColor.black
        }else{
            cell.backgroundColor = UIColor.white
            cell.selectionImage.image = nil
            cell.titleLabel?.textColor = UIColor.black
        }
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isMyClick{
            return
        }
        let d:Int = Int(indexPath.row / Int(itemsPerRow))
        let r:Int = Int(indexPath.row % Int(itemsPerRow))
        bingoObjectArray[d][r].isSelected = true
        bingoObjectArray[d][r].isMySelection = true
        self.selectedObject(bingoObj: bingoObjectArray[d][r])
        self.collectionView.reloadData()
        connection.sendData(data: ["message": (bingoObjectArray[d][r].number)])
        isMyClick = false
        self.statusLbl.text = "waiting..."
    }
}

extension MatrixViewController :UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = (sectionInsets.left * (itemsPerRow - 1)) + 20
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension MatrixViewController: P2PServiceHandlerDelegate {
    func didConnectedTo(_ serviceHandler: P2PServiceHandler, to peer: MCPeerID) {
        
    }
    
    func didFailToConnect(_ serviceHandler: P2PServiceHandler, with peer: MCPeerID) {
        
    }
    
    func connecting(_ serviceHandler: P2PServiceHandler, to peer: MCPeerID) {
        
    }
    
    func didRecieve(_ serviceHandler: P2PServiceHandler, data: [String : Any]) {
        
        DispatchQueue.main.async {
            if let val = data["message"] as? Int{
                if let bigObj = self.bingoObjectArray.flatMap({$0}).filter({$0.number == val}).first{
                    bigObj.isSelected = true
                    self.selectedObject(bingoObj: bigObj)
                }else{
                    
                }
                self.statusLbl.text = "your turn!.."
                self.isMyClick = true
                self.collectionView.reloadData()
            }else if let message = data["message"] as? String{
                self.showAlertWith(heading: "Message", message)
                self.navigationController?.popViewController(animated: true)
                self.isMyClick = false
            }
        }
    }
}

class MatrixViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var selectionImage: UIImageView!
}
class BingoObj: NSObject{
    var number:Int
    var xPos:Int
    var yPos:Int
    var Index: Int
    var isSelected: Bool = false
    var isMySelection: Bool = false
    
   
    init(number: Int,indexPath: Int) {
        self.number = number
        self.isSelected = false
        self.isMySelection = false
        let d:Int = Int(indexPath / Int(itemsPerRow))
        let r:Int = Int(indexPath % Int(itemsPerRow))
        self.Index = indexPath
        self.xPos = d
        self.yPos = r
    }
   
    
}
