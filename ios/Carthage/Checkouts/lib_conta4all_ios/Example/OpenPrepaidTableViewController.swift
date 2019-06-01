//
//  OpenPrepaidTableViewController.swift
//  Example
//
//  Created by Adriano Soares on 17/07/17.
//  Copyright © 2017 4all. All rights reserved.
//

import UIKit

class OpenPrepaidTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch PrepaidOption.init(rawValue: indexPath.row)! {
        case PrepaidOption.balance:
            cell.textLabel?.text = "Extrato"
        case PrepaidOption.token:
            cell.textLabel?.text = "Token"
        case PrepaidOption.transfer:
            cell.textLabel?.text = "Transferir"
        case PrepaidOption.deposit:
            cell.textLabel?.text = "Depositar"
        case PrepaidOption.cashOut:
            cell.textLabel?.text = "Sacar"
        }
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Lib4all.sharedInstance().openPrepaidScreen(PrepaidOption.init(rawValue: indexPath.row)!, in: self);
    }
    
    
    @IBAction func closeButtonTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }

}
