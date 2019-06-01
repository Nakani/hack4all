//
//  MerchantQRCodeGeneratorViewController.swift
//  Example
//
//  Created by Cristiano Matte on 24/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class MerchantQRCodeGeneratorViewController: UIViewController {

    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var qrcodeImage: CIImage!
    var transactionId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        transactionIdLabel.isHidden = true
        amountLabel.isHidden = true
        
        let manager = AFHTTPRequestOperationManager(baseURL: URL(string: "https://conta.homolog-interna.4all.com")!)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.timeoutInterval = 60
        
        let parameters : NSDictionary = ["merchantKey": "L+AxfH/NASop5fzKbqR7Yd5uBVIt9baCW68o8A9RBMo=", "amount": 2000]
        
        manager.post("/merchant/createTransaction",
                     parameters: parameters,
                     success: { (operation, responseObject) in
                        self.transactionId = (responseObject as! [String : Any])["transactionId"] as! String
                        DispatchQueue.main.async(execute: {
                            self.transactionIdLabel.text = "ID de transação: \(self.transactionId)"
                            self.amountLabel.text = "R$ 20,00"
                            self.transactionIdLabel.isHidden = false
                            self.amountLabel.isHidden = false
                            
                            self.generateQRCode()
                        })
            },
                     failure: { (operation, error) in
                        let alert = UIAlertView(title: "",
                            message: "\(error)",
                            delegate: nil,
                            cancelButtonTitle: nil,
                            otherButtonTitles: "OK")
                        alert.show()
        })
    }

    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func generateQRCode() {
        var string = "X_PAY_\(transactionId)_2000_Loja".data(using: String.Encoding.isoLatin1)!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        string = string.substring(to: (string.characters.index(string.startIndex, offsetBy: 3))) + "X" + string.substring(from: string.characters.index(string.startIndex, offsetBy: 3))
        
        let data = string.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter.outputImage
        
        let scaleX = 250 / qrcodeImage.extent.size.width
        let scaleY = 250 / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
                
        qrCodeImageView.image = UIImage(ciImage: transformedImage)
    }
    
}
