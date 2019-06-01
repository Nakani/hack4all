//
//  LocalConfContainerViewController.swift
//  Example
//
//  Created by Bruno Fernandes on 2/9/17.
//  Copyright © 2017 4all. All rights reserved.
//

import UIKit

class LocalConfContainerViewController: UIViewController, CallbacksDelegate {
    
    
    var vc: ComponentViewController!
    
    var paymentTypes: [AnyObject]!
    var brands: [AnyObject]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        paymentTypes = []
        brands = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetComponentView()
    }
    
    func setConfiguration(_ newPT:[Any], newB:[Any]) {
        self.paymentTypes = newPT as [AnyObject]
        self.brands = newB as [AnyObject]
        
        resetComponentView()
    }
    
    func resetComponentView() {
        if let vc = vc {
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        
        vc = ComponentViewController()
        
        //seta os payment types de acordo com o selecionado na tela
        vc.acceptedPaymentTypes = paymentTypes
        vc.acceptedBrands = brands
        
        //seta os brands de acordo com o selecionado na tela
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //MARK: Callbacks delegates
    func callbackShouldPerformButtonAction() -> Bool {
        print("callbackShouldPerformButtonAction")
        return true
    }
    
    func callbackLogin(_ sessionToken: String!, email: String!, phone: String!) {
        let alert = UIAlertView(title: "",
                                message: "phone: \(phone)\nemail: \(email)\nsessionToken: \(sessionToken)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
        alert.show()
    }
    
    func callbackPreVenda(_ sessionToken: String!, cardId: String!, paymentMode: PaymentMode, cvv: String!) {
        let manager = AFHTTPRequestOperationManager(baseURL: URL(string: "https://conta.homolog-interna.4all.com")!)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.timeoutInterval = 60
        
        var parameters : [String : Any] = ["merchantKey": "L+AxfH/NASop5fzKbqR7Yd5uBVIt9baCW68o8A9RBMo=",
                                           "amount": 10000,
                                           "waitForTransaction": true,
                                           "customerInfo": ["sessionToken": sessionToken,
                                                            "cardId": cardId]
        ]
        
        if paymentMode == .credit {
            let alert = UIAlertView(title: "",
                                    message: "sessionToken: \(sessionToken!)\ncardId: \(cardId)\npaymentMode: \(paymentMode.rawValue)",
                delegate: nil,
                cancelButtonTitle: nil,
                otherButtonTitles: "OK")
            alert.show()
            
            parameters["paymentMode"] = 1
            
            manager.post("/merchant/createAndPayTransaction",
                         parameters: parameters,
                         success: { (operation, responseObject) in
                            let transactionId = (responseObject as! [String : Any])["transactionId"] as! String
                            
                            let alert = UIAlertView(title: "",
                                                    message: "transactionId: \(transactionId)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            },
                         failure: { (operation, error) in
                            let alert = UIAlertView(title: "",
                                                    message: "\(error)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            })
        } else if paymentMode == .debit {
            parameters["paymentMode"] = 2
            manager.post("/merchant/createAndPayTransaction",
                         parameters: parameters,
                         success: { (operation, responseObject) in
                            
                            guard let urlString = (responseObject as! [String: Any])["debitTransactionURL"] as? String else {
                                let alert = UIAlertView(title: "",
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
                            let alert = UIAlertView(title: "",
                                                    message: "\(error)",
                                delegate: nil,
                                cancelButtonTitle: nil,
                                otherButtonTitles: "OK")
                            alert.show()
            })
            
        }
    }


}
