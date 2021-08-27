//
//  ViewController.swift
//  CemtrexLabsTest
//
//  Created by Pooja's MacBook Pro on 27/08/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var matchesTableView: UITableView!
    
    let menuArray = ["All Matches","Saved Matches"]
    var isSideViewOpen : Bool = false
    var isMatchedSelected : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideView.isHidden = true
        isSideViewOpen = false
        
        APIManager.shared.callAPI(onCompletion:  { (status, _) in
            if status {
                DispatchQueue.main.async {
                    self.isMatchedSelected = true
                    self.matchesTableView.reloadData()
                }
            }
        })
    }
    
    //MARK: Handle Menu UI
    func handleMenu()  {
        menuTableView.isHidden = false
        sideView.isHidden = false
        self.view.bringSubviewToFront(sideView)
        if !isSideViewOpen {
            isSideViewOpen = true//0
            sideView.frame = CGRect(x: 0, y: 78, width: 0, height: 399)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 0, height: 399)
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            sideView.frame = CGRect(x: 0, y: 88, width: 259, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 259, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            self.matchesTableView.isHidden = true
        } else {
            menuTableView.isHidden = true
            sideView.isHidden = true
            isSideViewOpen = false
            sideView.frame = CGRect(x: 0, y: 88, width: 259, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 259, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            
            sideView.frame = CGRect(x: 0, y: 88, width: 0, height: 499)
            menuTableView.frame = CGRect(x: 0, y: 0, width: 0, height: 499)
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
            self.matchesTableView.isHidden = false
            
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.handleMenu()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, matchViewController {
    
    //MARK: UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == matchesTableView {
            if isMatchedSelected {
                return APIManager.shared.details.count
            } else {
                return DBManager.shared.read().count
            }
        }
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == menuTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = menuArray[indexPath.row]
            return cell!
        } else if tableView == matchesTableView {
            if let matchCell = tableView.dequeueReusableCell(withIdentifier: "MatchTableViewCell") as? MatchTableViewCell {
                if isMatchedSelected {
                    matchCell.matchViewController = self
                    
                    let details = APIManager.shared.details[indexPath.row]
                    matchCell.matchLabel.text = details.name
                    matchCell.starButton.tag = indexPath.row
                    //
                    if  DBManager.shared.readDetail(detailsObj: details).count != 0 {
                        matchCell.starButton.setBackgroundImage(UIImage(named: "starSelected"), for: .normal)
                        matchCell.isStarSelected = true
                    } else {
                        matchCell.starButton.setBackgroundImage(UIImage(named: "star"), for: .normal)
                        matchCell.isStarSelected = false
                        
                    }
                } else {
                    // Get data from DB
                    let detail = DBManager.shared.read()[indexPath.row]
                    matchCell.matchLabel.text = detail.name
                    matchCell.starButton.tag = indexPath.row
                    matchCell.starButton.setBackgroundImage(UIImage(named: "starSelected"), for: .normal)
                }
                
                return matchCell
            }
        }
        return UITableViewCell()
    }
    
    //MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            if indexPath.row == 0 {
                isMatchedSelected = true
            } else  if indexPath.row == 1 {
                isMatchedSelected = false
            }
        }
        self.matchesTableView.reloadData()
        self.handleMenu()
    }
    
    //MARK: matchViewController Protocol
    func editButtonPressed(tag: Int, cell: MatchTableViewCell) {
        if isMatchedSelected {
            //Insert Into DB and change only that button icon
            let detail = APIManager.shared.details[tag]
            DBManager.shared.insert(detailsObj: detail)
            
            
            //reload cell
            let indexPath = IndexPath(item: tag, section: 0)
            self.matchesTableView.reloadRows(at: [indexPath], with: .fade)
            // when star selected
            if cell.isStarSelected  {
                DBManager.shared.deleteByID(detailsObj: detail)
            }
            self.matchesTableView.reloadRows(at: [indexPath], with: .fade)
            
        } else {
            let details = DBManager.shared.read()[tag]
            DBManager.shared.deleteByID(detailsObj: details)
            self.matchesTableView.reloadData()
        }
    }
}

