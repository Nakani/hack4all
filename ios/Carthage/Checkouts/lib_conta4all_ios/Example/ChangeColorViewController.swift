//
//  ChangeColorViewController.swift
//  Example
//
//  Created by Adriano Soares on 08/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

class ChangeColorViewController: UIViewController {

    var isChangeLoaderColor = false
    var isChangeButtonColor = false
    
    @IBOutlet weak var hexTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTouched(_ sender: AnyObject) {
        
        let color = UIColor(hexString: hexTextField.text)
        if isChangeButtonColor {
            Lib4all.setButtonColor(color, andGradient:nil)
        } else if isChangeLoaderColor {
            Lib4all.setLoaderColor(color)
            let loader = LoadingViewController();
            loader.startLoading(self, title: "Aguarde...", completion: nil)
            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                loader.finishLoading(nil);
            })

        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeButtonTouched(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
