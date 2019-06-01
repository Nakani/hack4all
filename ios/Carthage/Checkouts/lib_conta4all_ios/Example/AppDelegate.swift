//

//
//  AppDelegate.swift
//  Example
//
//  Created by 4all on 3/28/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.GA()
        Lib4all.setApplicationID("IOS_Example_1.16.0")
        Lib4all.setApplicationVersion("0")
        FirebaseApp.configure()
        Lib4all.setAnalytics(Analytics.self)
        
        Lib4all.setEnvironment(Environment.homologation);
        Lib4all.setChatDepartment("APP 4all");
        Lib4all.setEnableTransferWithCreditCard(true)
        
        var paymentTypes = [Any]()
        var brands       = [Any]()
        
        //Add a lista de tipos de pagamentos suportados no componente
        paymentTypes.append(PaymentType.Credit.rawValue)
        paymentTypes.append(PaymentType.Debit.rawValue)
        paymentTypes.append(PaymentType.PatRefeicao.rawValue)
        paymentTypes.append(PaymentType.PatAlimentacao.rawValue)
        paymentTypes.append(PaymentType.CheckingAccount.rawValue)
        Lib4all.setAcceptedPaymentTypes(paymentTypes)
        
        //Add a lista de tipos de bandeiras suportadas no componente
        brands.append(CardBrand.CardBrandVisa.rawValue)
        brands.append(CardBrand.CardBrandMastercard.rawValue)
        brands.append(CardBrand.CardBrandTicket.rawValue)
        Lib4all.setAcceptedBrands(brands)
        
//        Lib4allPreferences.sharedInstance().isBalanceFloatingButtonEnabled = false
        
//        Lib4all.setFonts("Gotham-Medium", andBoldFont: "Gotham-Bold")
//        
//        let backgroundColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
//        let primaryColor    = UIColor(red:0.31, green:0.89, blue:0.76, alpha:1.00)
//        let gradientColor   = UIColor(red:0.31, green:0.89, blue:0.76, alpha:1.00)
//        let lightFontColor  = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
//        let darkFontColor   = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00)
//        
//        Lib4all.setColors(backgroundColor, primaryColor: primaryColor, gradientColor: gradientColor, lightFontColor: lightFontColor, darkFontColor: darkFontColor)
//        
//        Lib4all.setFontsSizes(9.0, midFontSize: 11.0, regularFontSize: 13.0, titleFontSize: 22.0, subTitleFontSize: 16.0, navigationTitleFontSize: 16.0)
        
        
        Lib4all.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let handled = Lib4all.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return handled
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Lib4all.sharedInstance().applicationDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func GA () {
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.dispatchInterval = 5
        gai?.logger.logLevel = GAILogLevel.error  // remove before app release
        gai?.tracker(withTrackingId: "UA-79356569-16")
    }
    
}

