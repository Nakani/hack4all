//
//  ContainerViewController.swift
//  Example
//
//  Created by 4all on 3/29/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, CallbacksDelegate {

    var vc: ComponentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetComponentView()
        
    }
    
    func resetComponentView() {
        if let vc = vc {
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        
        vc = ComponentViewController()
        
        //Set delegate para callbacks pre e pós venda
        vc.delegate = self
        
        //Define o titulo do botão do componente
        vc.buttonTitleWhenNotLogged = "ENTRAR"
        
        //Define o titulo do botão após estar logado
        vc.buttonTitleWhenLogged = "FAZER RECARGA"
        
        //Define o tamanho que o componente deverá ter em tela de acordo com o container.
        vc.view.frame = self.view.bounds
        
        //Adiciona view do component ao controller
        self.view.addSubview(vc.view)
        
        //Adiciona a parte funcional ao container
        self.addChildViewController(vc)        

        vc.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //MARK: Callbacks delegates
    func callbackShouldPerformButtonAction() -> Bool {
        print("callbackShouldPerformButtonAction")
        return true
    }
    
    func callbackLogin(_ sessionToken: String!, email: String!, phone: String!) {
        let alert = UIAlertView(title: "Login",
                                message: "phone: \(phone)\nemail: \(email)\nsessionToken: \(sessionToken)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
        alert.show()
    }
    
    func callbackPreVenda(_ sessionToken: String!, cardId: String!, paymentMode: PaymentMode, cvv:String) {
        let manager = AFHTTPRequestOperationManager(baseURL: URL(string: "https://conta.homolog-interna.4all.com")!)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.timeoutInterval = 60
        
//        print("token: \(sessionToken)\ncardId/Checking: \(cardId)\npaymentMode: \(paymentMode.rawValue)\ncvv: \(cvv)")
        
        let parameters : NSMutableDictionary = ["merchantKey": "homolog_3/QIfSKOAk/R2mKFZSJNpUh0ozOuo89xThINGzrGKmE=",
                                                "amount": 10000,
                                                "waitForTransaction": true,
                                                "customerInfo": ["sessionToken": sessionToken,
                                                                 "cardId": cardId,
                                                                "paymentMode": paymentMode.rawValue]
        ]
//        if((cvv) != nil) {
//            parameters.setValue(cvv, forKey: "cvv")
//        }
        print(parameters as AnyObject)
        if(paymentMode == .debit) {
            manager.post("/merchant/createAndPayTransaction",
                         parameters: parameters,
                         success: { (operation, responseObject) in
                            
                            guard let urlString = (responseObject as! [String: Any])["debitTransactionURL"] as? String else {
                                let alert = UIAlertView(title: "Falha",
                                                        message: "Erro, url de débito não recebida",
                                                        delegate: nil,
                                                        cancelButtonTitle: nil,
                                                        otherButtonTitles: "OK")
                                alert.show()
                                
                                return;
                            }
                            
                            let url = URL(string: urlString)
                            
                            OperationQueue.main.addOperation({
                                Lib4all().openDebitWebView(in: self.parent!, with: url, completionBlock: { success in
                                    let alert = UIAlertView(title: "",
                                                            message: "success: \(success)",
                                        delegate: nil,
                                        cancelButtonTitle: nil,
                                        otherButtonTitles: "OK")
                                    alert.show()
                                })
                            })
            },
                         failure: { (operation, error) in
                            
                            let alert = UIAlertView(title: "Falha",
                                                    message: "\(error.localizedDescription)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            })

        } else {
//            let alert = UIAlertView(title: "",
//                                    message: "sessionToken: \(sessionToken!)\ncardId: \(cardId)\npaymentMode: \(paymentMode.rawValue)\ncvv: \(cvv)",
//                delegate: nil,
//                cancelButtonTitle: nil,
//                otherButtonTitles: "OK")
//            alert.show()
            
//            parameters["paymentMode"] = paymentMode.rawValue
            
            manager.post("/merchant/createAndPayTransaction",
                         parameters: parameters,
                         success: { (operation, responseObject) in
                            let transactionId = (responseObject as! [String: Any])["transactionId"] as! String
                            
                            let alert = UIAlertView(title: "Sucesso",
                                                    message: "transactionId: \(transactionId)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            },
                         failure: { (operation, error) in
                            let alert = UIAlertView(title: "Falha",
                                                    message: "\(error.localizedDescription)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            })

        }
    }
    
//    func callbackPosVenda(email: String!, telefone: String!, status: String!, dateTime: String!) {
//        
//        if status == ALL_OK{
//            //Pagamento realizado com sucesso
//        }else{
//            //Pagamento não foi realizado
//        }
//        
//    }
    

}
