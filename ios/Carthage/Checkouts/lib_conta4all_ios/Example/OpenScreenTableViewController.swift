//
//  OpenScreenTableViewController.swift
//  Example
//
//  Created by Cristiano Matte on 22/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class OpenScreenTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


    @IBAction func closeButtonTouched(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 9 {
            Lib4all().openAccountScreen(ProfileOption(rawValue: indexPath.row + 1)!, in: self);
        } else if indexPath.row == 9 {
            let clientReader = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomScannerVC") as! UINavigationController
            
            (clientReader.viewControllers[0] as! CustomScannerViewController).didScanQr = { value in
                
                if Lib4all().qrCodeIsSupported(value) {
                    clientReader.dismiss(animated: true, completion: {
                        Lib4all().handleQrCode(value, in: self, didFinishTransaction: {
                            let alert = UIAlertView(title: "",
                                                    message: "Callback qrcode",
                                                    delegate: nil,
                                                    cancelButtonTitle: nil,
                                                    otherButtonTitles: "OK")
                            alert.show()
                        })
                    })
                }
            }
            
            self.present(clientReader, animated: true, completion: nil)
        } else if indexPath.row == 10 {
            Lib4all.openAddCardScreen(with: self)
        }
    }
}
