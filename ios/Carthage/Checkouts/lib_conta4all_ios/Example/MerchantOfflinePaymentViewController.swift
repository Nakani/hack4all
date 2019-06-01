//
//  MerchantOfflinePaymentViewController.swift
//  Example
//
//  Created by Cristiano Matte on 24/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class MerchantOfflinePaymentViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var transactionString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = AFHTTPRequestOperationManager(baseURL: URL(string: "https://conta.homolog-interna.4all.com")!)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.timeoutInterval = 60
        
        let infos = transactionString.components(separatedBy: "&")
        let sessionId = infos[0].substring(from: infos[0].characters.index(infos[0].startIndex, offsetBy: 2))
        let transactionData = infos[1].substring(from: infos[1].characters.index(infos[1].startIndex, offsetBy: 2)).removingPercentEncoding!
        
        let parameters = ["merchantKey": "L+AxfH/NASop5fzKbqR7Yd5uBVIt9baCW68o8A9RBMo=", "sessionId": sessionId, "transactionData": transactionData]
        
        manager.post("/merchant/offlinePayTransaction",
                     parameters: parameters,
                     success: { (operation, responseObject) in
                        DispatchQueue.main.async(execute: { 
                            self.label.text = "Transação efetuada com sucesso."
                        })
            },
                     failure: { (operation, error) in
                        DispatchQueue.main.async(execute: {
                            self.label.text = "Erro ao processar transação."
                        })
            })
    }

    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
