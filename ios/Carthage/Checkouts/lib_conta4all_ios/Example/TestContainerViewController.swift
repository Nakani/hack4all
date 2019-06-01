//
//  TestContainerViewController.swift
//  Example
//
//  Created by Gabriel Miranda Silveira on 11/04/18.
//  Copyright © 2018 4all. All rights reserved.
//

import UIKit

class TestContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Lib4all.sharedInstance().userStateDelegate = self
        
//        let viewController = Lib4all.sharedInstance().getUserDataScreen(passingNavigation: self.navigationController!)
        let viewController = Lib4all.sharedInstance().getSettingsScreen(withLogoutEnabled:true)
        
        let navigation = BaseNavigationController(rootViewController: viewController)
        navigation.view.frame = containerView.frame
        
        self.addChildViewController(navigation)
        containerView.addSubview(navigation.view)
        navigation.didMove(toParentViewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
}

extension TestContainerViewController: UserStateDelegate {
    
    func userDidLogout() {
        print("SUCESSO")
    }
    
}
