//
//  ViewController.swift
//  Example
//
//  Created by 4all on 3/28/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UserStateDelegate, CallbacksDelegate {
    
    var container: ContainerViewController?
    var paymentTypeMenuIsOpen = false
    
    @IBOutlet weak var tableViewPaymentTypes: UITableView! {
        didSet {
            tableViewPaymentTypes.delegate = self
            tableViewPaymentTypes.dataSource = self
        }
    }
    @IBOutlet weak var tableViewPaymentTypesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cardContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Lib4all.setRequireCpfOrCnpj(true)
        
        Lib4all.sharedInstance().userStateDelegate = self
        
        
        let cardComponent = CardComponentViewController(cardId: nil, andInvisibleBackground:true)
        if let cardComponent = cardComponent {
            cardComponent.didSelectCardCompletionBlock = { cardId in
                cardComponent.changeCardId(cardId)
                if let cardId = cardId {
                    let alert = UIAlertView(title: "",
                                            message: "CardID: \(cardId)",
                        delegate: nil,
                        cancelButtonTitle: nil,
                        otherButtonTitles: "OK")
                    alert.show()
                }

            }
            cardComponent.view.frame = CGRect(x: 0.0, y: 0.0, width: self.cardContainerView.frame.size.width, height: self.cardContainerView.frame.size.height)
            self.cardContainerView.addSubview(cardComponent.view)
            self.addChildViewController(cardComponent)
            cardComponent.didMove(toParentViewController: self)
            self.cardContainerView.layer.cornerRadius        = 4.0;
            self.cardContainerView.layer.borderColor         = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            self.cardContainerView.layer.masksToBounds       = false;
            self.cardContainerView.layer.shadowOffset        = CGSize(width: 0, height: 1)
            self.cardContainerView.layer.shadowRadius        = 2;
            self.cardContainerView.layer.shadowColor         = UIColor.lightGray.cgColor;
            self.cardContainerView.layer.shadowOpacity       = 0.5;
            self.cardContainerView.backgroundColor = UIColor.white
        
        }
        
        //Lib4all.setBarStyle(UIBarStyle.black)
        
        Lib4allPreferences.sharedInstance().isNotificationHabilitatedBlock = {
            return false;
        }
        
        Lib4allPreferences.sharedInstance().didChangeNotificationSwitchBlock = { (isOn) in
            if isOn {
                print("Notification is on")
            } else {
                print("Notification is off")
            }
        }
        
    }
    
    @IBAction func callLoading(_ sender: AnyObject) {
        
//        let loadingView = LoadingViewController()
//        
//        loadingView.startLoading(self, title: "Aguarde...")

        let lib = Lib4all()

        lib.showProfileController(self)
    }
    
    @IBAction func callLogin(_ sender: AnyObject) {
        let lib = Lib4all()
        
        lib.callLogin(self) { phone, email, sessionToken in
            let alert = UIAlertView(title: "",
                                    message: "phone: \(phone)\nemail: \(email)\nsessionToken: \(sessionToken)",
                                    delegate: nil,
                                    cancelButtonTitle: nil,
                                    otherButtonTitles: "OK")
            alert.show()
        }
    }
    
    @IBAction func callLogout(_ sender: AnyObject) {
        let lib = Lib4all()

        lib.callLogout { success in
            if success {
                print("Logout Success");
            } else {
                print("Logout Error");
            }
        }
    }
    
    @IBAction func callGetData(_ sender: AnyObject) {
        let lib = Lib4all()
        
        if let data = lib.getAccountData() {
            let alert = UIAlertView(title: "",
                                    message: "customerId: \(data["customerId"])\nphone: \(data["phone"])\nemail: \(data["email"])\nsessionToken: \(data["sessionToken"])\ncpf:\(data["cpf"])\nname:\(data["fullName"])",
                                    delegate: nil,
                                    cancelButtonTitle: nil,
                                    otherButtonTitles: "OK")
            alert.show()
        }
    }
    
    @IBAction func callGetBlob(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Get Blob For Tef Payment", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "card id"
        }
        alert.addTextField {
            $0.placeholder = "tag"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            let cardID = alert.textFields![0].text!
            let tag = alert.textFields![1].text!
            let blob = "\(Lib4all.getBlobForTefPayment(cardID, tag: tag)!)&d=666666"
            let utfblob = blob.data(using: .utf8)!
            let encondedBlob = utfblob.base64EncodedString()
            
            self?.testBlob(blob: encondedBlob)
        }
        
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func testBlob(blob: String) {
        let url = URL(string: "https://conta.homolog-interna.4all.com/administrator/validateOfflineAuthorization")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = ["adminKey": "wBYI5JxVYuwsFeoqcRnatn963heJTgl1NGCEuyFNtrE=",
                                         "authorizationData": blob]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil else { print("error=\(error!)") ; return }
            
            if let httpStatus = response as? HTTPURLResponse {
                let alert = UIAlertController(title: "Status Code: \(httpStatus.statusCode)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    var component: ComponentViewController!
    
    @IBAction func showCardPicker(_ sender: AnyObject) {
        let lib = Lib4all()
        
        lib.showCardPicker(in: self) { cardId in
            let alert = UIAlertView(title: "",
                                    message: "cardId: \(cardId!)",
                                    delegate: nil,
                                    cancelButtonTitle: nil,
                                    otherButtonTitles: "OK")
            alert.show()
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.tag == 3 {
            switch sender.selectedSegmentIndex {
            case 0:
                Lib4all.setEnvironment(.homologation)
            case 1:
                Lib4all.setEnvironment(.production)
            default:
                Lib4all.setEnvironment(.homologation)
                break
            }

        } else if sender.tag == 2 {
            switch sender.selectedSegmentIndex {
            case 0:
                Lib4all.setRequireCpfOrCnpj(true)
            case 1:
                Lib4all.setRequireCpfOrCnpj(false)
            default:
                break
            }
        }
    }
    
    @IBAction func openSignUp(_ sender: Any) {
        Lib4all().callSignUp(self) { (phone, email, sessionToken) in
            let alert = UIAlertView(title: "",
                                    message: "phone: \(phone)\nemail: \(email)\nsessionToken: \(sessionToken)",
                delegate: nil,
                cancelButtonTitle: nil,
                otherButtonTitles: "OK")
            alert.show()
        }
    }
    
    @IBAction func chatButtonTouched() {
        Lib4all().showChat()
    }
    
    @IBAction func setLoaderColor(_ sender: Any) {
        let storyboard = self.storyboard
        guard let navigation = storyboard?.instantiateViewController(withIdentifier: "ChangeColorViewController") as? UINavigationController else {
            return
        }
        if let changeColorVC = navigation.viewControllers.first as? ChangeColorViewController {
            changeColorVC.isChangeLoaderColor = true
            self.present(navigation, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func setMainButtonColor(_ sender: Any) {
        let storyboard = self.storyboard
        guard let navigation = storyboard?.instantiateViewController(withIdentifier: "ChangeColorViewController") as? UINavigationController else {
            return
        }
        if let changeColorVC = navigation.viewControllers.first as? ChangeColorViewController {
            changeColorVC.isChangeButtonColor = true
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContainer" {
            container = segue.destination as? ContainerViewController
        }
    }
    
    func userDidLogout() {
        print("userDidLogout")
    }
    
    func userDidLogin() {
        print("userDidLogin")
    }
    @IBAction func openModal(_ sender: Any) {
        let modal = PopUpBoxViewController()
        modal.show(self, title: "Teste", description: "Enviaremos um e-mail para o endereço cadastrado(joa..@gmail.com) para que você possa recuperá-lo", imageMode: .Success) { 
            print("clicou no botão")
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 5 || (!paymentTypeMenuIsOpen && indexPath.row == 0) {
            paymentTypeMenuIsOpen = !paymentTypeMenuIsOpen
            tableView.reloadData()
            tableViewPaymentTypesHeightConstraint.constant = tableViewPaymentTypes.contentSize.height
            self.view.layoutSubviews()
        } else {
            var acceptedPaymentTypes = Lib4all.acceptedPaymentTypes() as! [Int]
            let paymentType = PaymentType(rawValue: indexPath.row)!
            
            if acceptedPaymentTypes.contains(paymentType.rawValue) {
                acceptedPaymentTypes.remove(at: acceptedPaymentTypes.index(of: paymentType.rawValue)!)
            } else {
                acceptedPaymentTypes.append(paymentType.rawValue)
            }
            Lib4all.setAcceptedPaymentTypes(acceptedPaymentTypes)
            tableView.reloadData()
            container?.resetComponentView()
        }
        
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if paymentTypeMenuIsOpen {
            return PaymentType.NumOfTypes.rawValue + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentTypeCellIdentifier")
        let title = cell?.viewWithTag(1) as! UILabel
        let check = cell?.viewWithTag(2) as! UIImageView
        
        if !paymentTypeMenuIsOpen {
            title.text = "ABRIR"
            check.isHidden = true
        } else {
            
            switch indexPath.row {
            case PaymentType.Credit.rawValue:
                title.text = "Crédito"
            case PaymentType.Debit.rawValue:
                title.text = "Débito"
            case PaymentType.CheckingAccount.rawValue:
                title.text = "Checking"
            case PaymentType.PatRefeicao.rawValue:
                title.text = "Pat Refeição"
            case PaymentType.PatAlimentacao.rawValue:
                title.text = "Pat Alimentação"
            case 5:
                title.text = "FECHAR"
            default: title.text = "Label"
            }
            
            let acceptedPaymentTypes = Lib4all.acceptedPaymentTypes() as! [Int]
            check.isHidden = !acceptedPaymentTypes.contains(indexPath.row)
            
        }
        return cell!
    }
}
