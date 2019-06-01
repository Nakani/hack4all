//
//  SelectedCardBrandsTableViewController.swift
//  Example
//
//  Created by Cristiano Matte on 30/09/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class SelectedCardBrandsTableViewController: UITableViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for brand in Lib4all.acceptedBrands() as! [Int] {
            tableView.cellForRow(at: IndexPath(row: brand-1, section: 0))!.accessoryType = .checkmark
        }
    }
    
    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        var brands = [NSNumber]()
        
        for i in 1...9 {
            let cell = tableView.cellForRow(at: IndexPath(row: i-1, section: 0))!

            if cell.accessoryType == .checkmark {
                brands += [NSNumber(value: i as Int)]
            }
            
            Lib4all.setAcceptedBrands(brands)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
    }
}
