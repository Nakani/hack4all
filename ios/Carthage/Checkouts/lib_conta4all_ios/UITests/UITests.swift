//
//  UITests.swift
//  UITests
//
//  Created by Adriano Soares on 06/06/17.
//  Copyright © 2017 4all. All rights reserved.
//

import XCTest

class UITests: XCTestCase {
    
    var app : XCUIApplication!
    
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
 
        app = XCUIApplication()
        app.launchEnvironment = ["animations": "0"]
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogout() {
        logout()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements

        XCTAssertTrue(elementsQuery.buttons["ENTRAR"].exists, "UserShouldLogout")
    }
    
    
    func testSignIn() {
        signIn()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        XCTAssertTrue(elementsQuery.buttons["FAZER RECARGA"].exists, "UserShouldSignIn")
    }
    
    func testSignUp() {
        signUp()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        XCTAssertTrue(elementsQuery.buttons["FAZER RECARGA"].exists, "UserShouldSignUp")
        
    }
    
    func testProfile() {
        signIn()
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.buttons["Perfil"].tap()

        XCTAssertTrue(app.cells.count == 8, "Profile Should Have 8 Sections")
        XCTAssertTrue(app.staticTexts["Extrato"].exists, "Profile Should Have Extrato")
        XCTAssertTrue(app.staticTexts["Assinaturas"].exists, "Profile Should Have Assinaturas")
        XCTAssertTrue(app.staticTexts["Dados pessoais"].exists, "Profile Should Have Dados Pessoais")
        XCTAssertTrue(app.staticTexts["Meus cartões"].exists, "Profile Should Have Meus cartões")
        XCTAssertTrue(app.staticTexts["Perfil família"].exists, "Profile Should Have Perfil família")
        XCTAssertTrue(app.staticTexts["Configurações"].exists, "Profile Should Have Configurações")
        XCTAssertTrue(app.staticTexts["Ajuda"].exists, "Profile Should Have Ajuda")
        XCTAssertTrue(app.staticTexts["Sobre"].exists, "Profile Should Have Sobre")
    }
    
    
    
    //MARK: HELPERS
    func randomEmail () -> String {
        var email = ""
        
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var c = charSet.characters.map { String($0) }
        for _ in (1...24) {
            email.append(c[Int(arc4random()) % c.count])
        }
        email.append("@4all.mobi")
        return email
    }
    
    func randomPhone () -> String {
        var number = "5099"
        for _ in 0..<7 {
            number.append("\(arc4random()%9)")
        }
        
        return number
    }
    
    func logout() {
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        elementsQuery.buttons["Fazer Logout"].tap()
    }
    
    func signUp() {
        logout()
        
        app.scrollViews.otherElements.buttons["Fazer Login"].tap()
        
        let telefoneOuEMailTextField = app.textFields["Telefone ou e-mail"]
        telefoneOuEMailTextField.tap()
        
        
        telefoneOuEMailTextField.typeText(randomPhone())
        
        let proximoButton = app.buttons["Próximo"]
        proximoButton.tap()
        
        var element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .textField).element.typeText("Ui Test")
        proximoButton.tap()
        proximoButton.tap()
        
        let element3 = element.children(matching: .other).element(boundBy: 1)
        var element2 = element3.children(matching: .other).element
        element2.children(matching: .textField).element(boundBy: 0).tap()
        
        app.typeText("4")
        app.typeText("4")
        app.typeText("4")
        app.typeText("4")
        app.typeText("4")
        app.typeText("4")
        
        app.buttons["Confirmar"].tap()
        app.textFields["E-mail"].tap()
        
        element2 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element = element2.children(matching: .other).element
        element.children(matching: .textField).element.typeText(randomEmail())
        
        proximoButton.tap()
        app.textFields["Data de nascimento"].typeText("07121987")
        proximoButton.tap()
        
        let secureTextField = element.children(matching: .secureTextField).element
        secureTextField.typeText("Asd123")
        proximoButton.tap()
        secureTextField.typeText("Asd123")
        proximoButton.tap()
        element2.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).tap()
        app.buttons["Concordo"].tap()
        
        sleep(2)
        app.buttons["Começar a usar o aplicativo 4all"].tap()
        sleep(2)
        app.alerts.buttons["OK"].tap()
    }
    
    func signIn() {
        logout()
        
        app.scrollViews.otherElements.buttons["Fazer Login"].tap()
        
        let telefoneOuEMailTextField = app.textFields["Telefone ou e-mail"]
        telefoneOuEMailTextField.tap()
        telefoneOuEMailTextField.typeText("51981556281")
        app.buttons["Próximo"].tap()
        app.secureTextFields["Senha"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .secureTextField).element.typeText("Asd123")
        app.buttons["PRÓXIMO"].tap()
        
        sleep(4)
        XCTAssertTrue(app.alerts.count > 0)
        app.alerts.buttons["OK"].tap()
    }
}
