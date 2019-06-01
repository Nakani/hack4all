//
//  ClientQRCodeGeneratorViewController.swift
//  Example
//
//  Created by Cristiano Matte on 24/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class ClientQRCodeGeneratorViewController: UIViewController {

    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    var qrcodeImage: CIImage!
    var transactionString: String!
    var transactionId: String!
    var amount: Int32!
    
    var lib = Lib4all.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Remove o "X"
        transactionString = transactionString.substring(to: (transactionString.index(transactionString.startIndex, offsetBy: 3))) +
            transactionString.substring(from: transactionString.index(transactionString.startIndex, offsetBy: 4))
        
        // Decodifica
        let data = Data(base64Encoded: transactionString, options: NSData.Base64DecodingOptions(rawValue: 0))!
        transactionString = String(data: data, encoding: String.Encoding.isoLatin1)
        
        // Obtém as infos
        let infos = transactionString.components(separatedBy: "_")
        transactionId = infos[2]
        amount = Int32(infos[3])!
        
        self.transactionIdLabel.text = "ID de transação: \(transactionId)"
        self.amountLabel.text = "R$ 20,00"
        self.cardIdLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let card = (CreditCardsList.sharedList() as AnyObject).getDefaultCard(), Lib4all().hasUserLogged() else {
            let alert = UIAlertController(title: "Atenção",
                                          message: "Deve existir usuário logado e com cartão cadastrado para fazer pagamento offline.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //TODO: FIX
        /*guard Lib4allPreferences.sharedInstance().acceptedBrands.contains(card.brandId) &&
            (Lib4allPreferences.sharedInstance().acceptedPaymentMode.rawValue & card.type.rawValue != 0) else {
            let alert = UIAlertController(title: "Atenção",
                                          message: "Este cartão não é aceito neste aplicativo. Por favor, escolha outro cartão.",
                                          preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
                
            self.presentViewController(alert, animated: true, completion: nil)
                
            return;
        }*/
        
        self.cardIdLabel.text = "Cartão: \(card.getMaskedPan())"
        self.cardIdLabel.isHidden = false;
        
        let qrCodeString = Lib4all().generateOfflinePaymentString(forTransactionID: transactionId, cardID: card.cardId, amount: amount, campaignUUID: nil, couponUUID: nil)
        let qrCodeData = qrCodeString?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(qrCodeData, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        qrcodeImage = filter.outputImage
        
        let scaleX = 250 / qrcodeImage.extent.size.width
        let scaleY = 250 / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        qrCodeImageView.image = UIImage(ciImage: transformedImage)
    }
    
    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    
}
