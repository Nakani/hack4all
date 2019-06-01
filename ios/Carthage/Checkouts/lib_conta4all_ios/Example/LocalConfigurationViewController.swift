//
//  LocalConfigurationViewController.swift
//  Example
//
//  Created by Bruno Fernandes on 2/8/17.
//  Copyright © 2017 4all. All rights reserved.
//

import UIKit

class LocalConfigurationViewController: UIViewController {
    
    var container: LocalConfContainerViewController?
    
    //switches tipos de pagamento:
    @IBOutlet weak var creditSwitch: UISwitch!
    @IBOutlet weak var debitSwitch: UISwitch!
    @IBOutlet weak var checkingSwitch: UISwitch!

    //switches bandeiras:
    @IBOutlet weak var visaSwitch: UISwitch!
    @IBOutlet weak var masterSwitch: UISwitch!
    @IBOutlet weak var dinersSwitch: UISwitch!
    @IBOutlet weak var eloSwitch: UISwitch!
    @IBOutlet weak var amexSwitch: UISwitch!
    @IBOutlet weak var discoverSwitch: UISwitch!
    @IBOutlet weak var auraSwitch: UISwitch!
    @IBOutlet weak var jcbSwitch: UISwitch!
    @IBOutlet weak var hiperSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onApplyChangesButtonClick(_ sender: AnyObject) {
        
        var paymentTypes = [Any]()
        
        if (creditSwitch.isOn) {
            paymentTypes.append(PaymentType.Credit.rawValue)
        }
        
        if (debitSwitch.isOn) {
            paymentTypes.append(PaymentType.Debit.rawValue)
        }
        
        if checkingSwitch.isOn {
            paymentTypes.append(PaymentType.CheckingAccount.rawValue)
        }
        
        var brands = [Any]()
        
        if (visaSwitch.isOn){
            brands.append(CardBrand.CardBrandVisa.rawValue)
        }
        
        if (masterSwitch.isOn) {
            brands.append(CardBrand.CardBrandMastercard.rawValue)
        }
        
        if (dinersSwitch.isOn) {
            brands.append(CardBrand.CardBrandDiners.rawValue)
        }
        
        if (eloSwitch.isOn) {
            brands.append(CardBrand.CardBrandElo.rawValue)
        }
        
        if (amexSwitch.isOn) {
            brands.append(CardBrand.CardBrandAmex.rawValue)
        }
        
        if (discoverSwitch.isOn) {
            brands.append(CardBrand.CardBrandDiscover.rawValue)
        }
        
        if (auraSwitch.isOn) {
            brands.append(CardBrand.CardBrandAura.rawValue)
        }
        
        if (jcbSwitch.isOn) {
            brands.append(CardBrand.CardBrandJCB.rawValue)
        }
        
        if (hiperSwitch.isOn) {
            brands.append(CardBrand.CardBrandHiper.rawValue)
        }
        
        container?.setConfiguration(paymentTypes, newB: brands)
        
        let alert = UIAlertView(title: "", message: "Configurações alteradas", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onBackButtonTouch(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLocalConfContainer" {
            container = segue.destination as? LocalConfContainerViewController
            
        }
    }
}
