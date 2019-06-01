//
//  MainButtonAction.m
//  Example
//
//  Created by 4all on 02/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "LoginPaymentAction.h"
#import "CreditCardsList.h"
#import "Lib4allPreferences.h"
#import "User.h"
#import "CardAdditionFlowController.h"
#import "SignFlowController.h"
#import "SignInViewController.h"
#import "PaymentFlowController.h"
#import "Lib4allPreferences.h"
#import "ComponentViewController.h"

@interface LoginPaymentAction() <UIActionSheetDelegate>

@end

@implementation LoginPaymentAction

-(void)callMainAction:(UIViewController *)controller
             delegate:(id<CallbacksDelegate>)delegate
 acceptedPaymentTypes:(NSArray*) paymentTypes
       acceptedBrands:(NSArray *) brands
      checkingAccount:(NSString *)checkingAccount{
    
    self.controller = controller;
    self.delegate   = delegate;
    
    BOOL shouldContinue = true;
    BOOL payWithChecking = checkingAccount != nil;

    /*
     * Chama o callback onClick do botão, caso seja configurado pelo chamador
     */
    if ([self.delegate respondsToSelector:@selector(callbackShouldPerformButtonAction)]) {
        shouldContinue = [self.delegate callbackShouldPerformButtonAction];
    }
    
    //NSArray * acceptedPaymentMode = [[Lib4allPreferences sharedInstance] acceptedPaymentTypes];
    
    if (shouldContinue) {
        /*
         * Se usuário está logado, prossegue com o pagamento.
         * Caso contrário, abre a tela de login/cadastro com pagamento.
         */
        if ([[User sharedUser] currentState] == UserStateLoggedIn) {
            CreditCard *defaultCard = [[CreditCardsList sharedList] getDefaultCard];
            
            /*
             * Caso não seja pagamento com conta pré-paga
             * Caso o usuário já possua cartão adicionado, paga com este cartão.
             * Caso contrário, abre a tela de adição de cartão
             */
            if (!payWithChecking) {
                if (defaultCard != nil && ![defaultCard.cardId isEqualToString:@""]) {
                    /*
                     * Se o cartão selecionado é de modalidade ou bandeira não aceita, exibe alerta de erro.
                     * Se o cartão é de crédito e débito e ambos são aceitos, exibe action sheet para
                     * que seja selecionado o modo de pagamento.
                     * Se apenas crédito ou débito são aceitos e o cartão selecionado possui a modalidade
                     * aceita, chama o callback pré venda.
                     */
                    if (![self cardIsAccepted:defaultCard withAcceptedPaymentTypes:paymentTypes andAcceptedBrands:brands]) {
                        
                        NSString *message = @"Este cartão não é aceito neste aplicativo. Por favor, escolha outro cartão.";
                        
                        if (_isQrCodePayment) {
                            message = @"Este cartão não é aceito neste estabelecimento. Por favor, escolha outro cartão.";
                        }
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção"
                                                                                       message:message
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                        [alert addAction:ok];
                        
                        [controller presentViewController:alert animated:YES completion:nil];
                    } else if (defaultCard.type == CardTypeCreditAndDebit && [paymentTypes containsObject:@(Credit)] && [paymentTypes containsObject:@(Debit)]) {
                        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"Cancelar"
                                                                   destructiveButtonTitle:nil
                                                                        otherButtonTitles:@"Pagar com Crédito", @"Pagar com Débito", nil];
                        [actionSheet showInView:self.controller.view];
                    } else if(defaultCard.askCvv) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pagamento"
                                                                                                 message:@"Informe o código de segurança (CVV) localizado na parte de trás do seu cartão"
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            textField.placeholder = @"CVV";
                            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                        }];
                        [alertController addAction:[UIAlertAction
                                                    actionWithTitle:@"Pagar"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                            
                                                        PaymentMode payMode = PaymentModeCredit;
                                                        if (defaultCard.type == CardTypeCredit) payMode = PaymentModeCredit;
                                                        if (defaultCard.type == CardTypeDebit) payMode = PaymentModeDebit;
                                                        if (defaultCard.type == CardTypePatRefeicao) payMode = PaymentModePatRefeicao;
                                                        if (defaultCard.type == CardTypePatAlimentacao) payMode = PaymentModePatAlimentacao;
                                                        
                                                        NSArray *textFields = alertController.textFields;
                                                        UITextField *cvvField = textFields[0];
                                                        [self callPrevendaWithCardId:defaultCard.cardId paymentMode:payMode cvv:cvvField.text];
                                                    }]];
                        [alertController addAction:[UIAlertAction
                                                    actionWithTitle:@"Cancelar"
                                                    style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        
                                                    }]];
                        
                        [controller presentViewController:alertController animated:YES completion:nil];
                    } else {
                        PaymentMode payMode = PaymentModeCredit;
                        if (defaultCard.type == CardTypeCredit) payMode = PaymentModeCredit;
                        if (defaultCard.type == CardTypeDebit) payMode = PaymentModeDebit;
                        if (defaultCard.type == CardTypePatRefeicao) payMode = PaymentModePatRefeicao;
                        if (defaultCard.type == CardTypePatAlimentacao) payMode = PaymentModePatAlimentacao;
                        
                        [self callPrevendaWithCardId:defaultCard.cardId paymentMode:payMode cvv:nil];
                    }
                } else {
                    // Inicia o fluxo de adição de cartão e finaliza com o pagamento
                    CardAdditionFlowController *flowController = [[CardAdditionFlowController alloc] initWithAcceptedPaymentTypes:paymentTypes andAcceptedBrands:brands];
                    flowController.loginWithPaymentCompletion = ^(NSString *sessionToken, NSString *cardId, NSString *cvv) {
                        PaymentMode payMode = PaymentModeCredit;
                        if (defaultCard.type == CardTypeCredit) payMode = PaymentModeCredit;
                        if (defaultCard.type == CardTypeDebit) payMode = PaymentModeDebit;
                        if (defaultCard.type == CardTypePatRefeicao) payMode = PaymentModePatRefeicao;
                        if (defaultCard.type == CardTypePatAlimentacao) payMode = PaymentModePatAlimentacao;
                        
                        [self callPrevendaWithCardId:cardId paymentMode:payMode cvv:cvv];

                    };
                    flowController.isCardOCREnabled = [Lib4allPreferences sharedInstance].isCardOCREnabled;
                    [flowController startFlowWithViewController:self.controller];
                }
            } else {
                if ([paymentTypes containsObject:@(CheckingAccount)]) {
                    PaymentMode payMode = PaymentModeChecking;
                    
                    [self callPrevendaWithCardId:checkingAccount paymentMode:payMode cvv:nil];
                }else{
                    //Pagamento escolhido é a conta pré paga, mas ela não aceita nesta transação (ou aplicativo)
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção"
                                                                                   message:@"Forma de pagamento não é aceita pra essa transação."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:ok];
                    
                    [controller presentViewController:alert animated:YES completion:nil];
                }

            }
        } else {
            SignFlowController *signFlowController = [[SignFlowController alloc] initWithAcceptedPaymentTypes: paymentTypes andAcceptedBrands: brands];
            signFlowController.requirePaymentData = YES;
            
            // Nos casos de login de usuário existente, será chamado o callbackLogin ao finalizar o login
            signFlowController.loginCompletion = ^(NSString *phoneNumber, NSString *emailAddress, NSString *sessionToken) {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(callbackLogin:email:phone:)]) {
                    [self.delegate callbackLogin:sessionToken email:emailAddress phone:phoneNumber];
                }
            };
            
            // Nos casos de cadastro de novo usuário, será chamado o callBackPreVenda ao finalizar o login
            signFlowController.loginWithPaymentCompletion = ^(NSString *sessionToken, NSString *cardId, NSString *cvv) {
                if (self.delegate != nil) {
                    CreditCard *card = [[CreditCardsList sharedList] getCardWithID:cardId];
                    /*
                     * Se o cartão selecionado é de modalidade não aceita, exibe alerta de erro.
                     * Se o cartão é de crédito e débito e ambos são aceitos, exibe action sheet para
                     * que seja selecionado o modo de pagamento.
                     * Se apenas crédito ou débito são aceitos e o cartão selecionado possui a modalidade
                     * aceita, chama o callback pré venda.
                     */
                    
                    if (payWithChecking || [cardId  isEqual: @"CHECKING_ACCOUNT"]) {
                        if ([paymentTypes containsObject:@(CheckingAccount)]) {
                            PaymentMode payMode = PaymentModeChecking;
                            
                            [self callPrevendaWithCardId:@"CHECKING_ACCOUNT" paymentMode:payMode cvv:nil];
                        }else{
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção"
                                                                                           message:@"Forma de pagamento não é aceita pra essa transação."
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:ok];
                            
                            [controller presentViewController:alert animated:YES completion:nil];
                        }
                        
                    }else{
                    
                        if (![self cardIsAccepted:card withAcceptedPaymentTypes:paymentTypes andAcceptedBrands:brands]) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção"
                                                                                           message:@"Este cartão não é aceito neste aplicativo. Por favor, escolha outro cartão."
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:ok];
                            
                            [controller presentViewController:alert animated:YES completion:nil];
                        } else if (card.type == CardTypeCreditAndDebit) {
                            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Cancelar"
                                                                       destructiveButtonTitle:nil
                                                                            otherButtonTitles:@"Pagar com Crédito", @"Pagar com Débito", nil];
                            [actionSheet showInView:self.controller.view];
                        } else if(card.askCvv) {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pagamento"
                                                                                                     message:@"Informe o código de segurança (CVV) localizado na parte de trás do seu cartão"
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                textField.placeholder = @"CVV";
                                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                            }];
                            [alertController addAction:[UIAlertAction
                                                        actionWithTitle:@"Pagar"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            PaymentMode payMode = PaymentModeCredit;
                                                            if (card.type == CardTypeCredit) payMode = PaymentModeCredit;
                                                            if (card.type == CardTypeDebit) payMode = PaymentModeDebit;
                                                            if (card.type == CardTypePatRefeicao) payMode = PaymentModePatRefeicao;
                                                            if (card.type == CardTypePatAlimentacao) payMode = PaymentModePatAlimentacao;
                                                            
                                                            NSArray *textFields = alertController.textFields;
                                                            UITextField *cvvField = textFields[0];
                                                            [self callPrevendaWithCardId:card.cardId paymentMode:payMode cvv:cvvField.text];
                                                        }]];
                            [alertController addAction:[UIAlertAction
                                                        actionWithTitle:@"Cancelar"
                                                        style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            
                                                            
                                                        }]];
                            
                            [controller presentViewController:alertController animated:YES completion:nil];
                        } else {
                            
                            //Inicia com o modo padrão de Crédito
                            PaymentMode payMode = PaymentModeCredit;
                            
                            if ([paymentTypes containsObject:@(Credit)])
                                payMode = PaymentModeCredit;
                            else if ([paymentTypes containsObject:@(Debit)])
                                payMode = PaymentModeDebit;
                            else if ([paymentTypes containsObject:@(PatRefeicao)])
                                payMode = PaymentModePatRefeicao;
                            else if ([paymentTypes containsObject:@(PatAlimentacao)])
                                payMode = PaymentModePatAlimentacao;
                            else
                                NSAssert(false, @"Tipo de pagamento não reconhecido!");
                            
                            [self callPrevendaWithCardId:card.cardId paymentMode:payMode cvv:cvv];
                        }
                    }

                }
            };
            
            UINavigationController *navigationController = [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]]
                                                            instantiateViewControllerWithIdentifier:@"LoginVC"];
            SignInViewController *viewController = [[navigationController viewControllers] objectAtIndex:0];
            viewController.signFlowController = signFlowController;
            
            [controller presentViewController:navigationController animated:true completion:nil];
        }
    }

}

- (bool) cardIsAccepted:(CreditCard *) card withAcceptedPaymentTypes: (NSArray*) acceptedPaymentTypes andAcceptedBrands: (NSArray *) acceptedBrands {
    
    BOOL isValid = NO;
    
    //verifica os meios de pagamento do cartão
    
    //Verifica crédito
    if ((card.type == CardTypeCredit) && ([acceptedPaymentTypes containsObject:@(Credit)])) isValid = YES;
    
    //Verifica débito
    if ((card.type == CardTypeDebit) && ([acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    //Verifica ambos
    if ((card.type == CardTypeCreditAndDebit) && ([acceptedPaymentTypes containsObject:@(Credit)] || [acceptedPaymentTypes containsObject:@(Debit)])) isValid = YES;
    
    if ((card.type == CardTypePatRefeicao) && ([acceptedPaymentTypes containsObject:@(PatRefeicao)])) isValid = YES;
        
    if ((card.type == CardTypePatAlimentacao) && ([acceptedPaymentTypes containsObject:@(PatAlimentacao)])) isValid = YES;
    
    //Verifica brands
    if (![acceptedBrands containsObject:card.brandId]) isValid = NO;
    
    
    return isValid;
    
}

// MARK: - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CreditCard *defaultCard = [[CreditCardsList sharedList] getDefaultCard];
    
    if (buttonIndex == 0) { // Crédito
        [self callPrevendaWithCardId:defaultCard.cardId paymentMode:PaymentModeCredit cvv:nil];
    } else if (buttonIndex == 1) { // Débito
        [self callPrevendaWithCardId:defaultCard.cardId paymentMode:PaymentModeDebit cvv:nil];
    }
}

// MARK: - Services

- (void)callPrevendaWithCardId:(NSString *)cardId paymentMode:(PaymentMode)paymentMode cvv:(NSString *)cvv{
    
    if ([self.delegate respondsToSelector:@selector(callbackPreVenda:cardId:paymentMode:cvv:)]) {
        PaymentFlowController *paymentFlowController = [[PaymentFlowController alloc] init];
        paymentFlowController.paymentCompletion = ^() {
            if (paymentMode == PaymentModeChecking) {
                [self.delegate callbackPreVenda:[[User sharedUser] token] cardId:@"CHECKING_ACCOUNT" paymentMode:paymentMode cvv:cvv];
            }else{
                CreditCard *card = [[CreditCardsList sharedList] getCardWithID:cardId];
                [self.delegate callbackPreVenda:[[User sharedUser] token] cardId:card.cardId paymentMode:paymentMode cvv:cvv];
            }
            ComponentViewController *currentComponent = [Lib4allPreferences sharedInstance].currentVisibleComponent;
            [currentComponent updateComponentViews];
        };
        [paymentFlowController startFlowWithViewController:self.controller];
        
    } else if ([self.delegate respondsToSelector:@selector(callbackPreVenda:cardId:paymentMode:)]) {
        PaymentFlowController *paymentFlowController = [[PaymentFlowController alloc] init];
        paymentFlowController.paymentCompletion = ^() {
            if (paymentMode == PaymentModeChecking) {
                [self.delegate callbackPreVenda:[[User sharedUser] token] cardId:@"CHECKING_ACCOUNT" paymentMode:paymentMode cvv:cvv];
            }else{
                CreditCard *card = [[CreditCardsList sharedList] getCardWithID:cardId];
                [self.delegate callbackPreVenda:[[User sharedUser] token] cardId:card.cardId paymentMode:paymentMode cvv:cvv];
            }
            ComponentViewController *currentComponent = [Lib4allPreferences sharedInstance].currentVisibleComponent;
            [currentComponent updateComponentViews];
        };
        [paymentFlowController startFlowWithViewController:self.controller];
    }
}

@end
