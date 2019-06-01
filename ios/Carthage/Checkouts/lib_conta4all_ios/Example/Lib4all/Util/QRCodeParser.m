//
//  QRCodeParser.m
//  Example
//
//  Created by 4all on 24/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "QRCodeParser.h"

@implementation QRCodeParser
-(NSMutableDictionary *)generateDictionaryFromQRContent:(NSString *)contentQrCode {
    
    NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
    
    
    //Modelo antigo de QRCode
    if ([contentQrCode containsString:@"FINTECH"]){
        [infoDictionary setValue:@YES forKey:@"fintechModel"];
        for (NSString *param in [contentQrCode componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [infoDictionary setObject:[elts lastObject] forKey:[elts firstObject]];
        }
        
        //Novo QR Code(query string)
    }else{
        
        //Remove X inserido no meio da string
        NSString *transactionString = [[contentQrCode substringToIndex:3] stringByAppendingString:[contentQrCode substringFromIndex:4]];
        
        //Decodifica o base64
        NSData *data = [[NSData alloc] initWithBase64EncodedString:transactionString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        transactionString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([[transactionString uppercaseString] containsString:@"X_PAY"]) {
            NSArray *itemsSplit = [transactionString componentsSeparatedByString:@"_"];
            
            
            //Maior que 5 itens significa que não suporta pois contee itens do cupom
            if (itemsSplit.count > 6) {
                return nil;
            }
            
            [infoDictionary setValue:@NO forKey:@"fintechModel"];
            [infoDictionary setValue:itemsSplit[2] forKey:@"transactionId"];
            [infoDictionary setValue:itemsSplit[3] forKey:@"amount"];
            [infoDictionary setValue:itemsSplit[4] forKey:@"merchantName"];
            
            if (itemsSplit.count == 6) {
                [infoDictionary setValue:itemsSplit[5] forKey:@"cnpj"];
            }
            
            [infoDictionary setValue:@NO forKey:@"cancellation"];
            
            for (NSString *param in [transactionString componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [infoDictionary setObject:[elts lastObject] forKey:[elts firstObject]];
            }
        } else if ([[transactionString uppercaseString] containsString:@"X_CNC"]) {
            
            //X_CNC_transactionId_amount_tradingName_documentNumber;
            NSArray *itemsSplit = [transactionString componentsSeparatedByString:@"_"];
            [infoDictionary setValue:@NO forKey:@"fintechModel"];
            [infoDictionary setValue:itemsSplit[2] forKey:@"transactionId"];
            [infoDictionary setValue:itemsSplit[3] forKey:@"amount"];
            [infoDictionary setValue:itemsSplit[4] forKey:@"merchantName"];
            if (itemsSplit.count > 5) {
                [infoDictionary setValue:itemsSplit[5] forKey:@"cnpj"];
            }
            
            [infoDictionary setValue:@YES forKey:@"cancellation"];
            
            
        }else{
            infoDictionary = nil;
        }
        
    }
    return infoDictionary;
}


/*  ===== PADRÃO QR CODE FINTECH =====
 
 a - FINTECH (este campo será fixo), presente sempre que for um QRCode Fintech
 b - versão, sempre presente;
 c - tipo (PAY_ONLINE - ec online, PAY_OFFLINE - ec offline), sempre presente;
 
 Estes campos estão presentes somente nos tipos PAY_ONLINE:
 
 d - transactionId (opcional em caso de EC offline);
 e - amount, em centavos;
 f - merchant name;
 g - número de parcelas (opcional, caso não venha, tratar como 1);
 h - tipos de pagamento aceitos (conforme definido no email do natanael, olhar abaixo)
 i - bandeiras (conforme definido no email do natanael, olhar abaixo)
 j - Merchant aceita pagamento com cliente offline ("T" = true, "F" = false), campo obrigatório
 
 Estes campos estão presentes somente nos tipos PAY_OFFLINE:
 
 d - transactionId (opcional em caso de EC offline);
 e - amount, em centavos;
 f - merchant name;
 g - número de parcelas (opcional, caso não venha, tratar como 1);
 h - tipos de pagamento aceitos (conforme definido no email do natanael, olhar abaixo)
 i - bandeiras (conforme definido no email do natanael, olhar abaixo)
 j - Merchant aceita pagamento com cliente offline ("T" = true, "F" = false), campo obrigatório
 k - blob cifrado merchant offline (opcional, somente quando tipo PAY_OFFLINE)
 l - merchantKeyId (opcional, somente quando tipo PAY_OFFLINE)
 
 Todos os campos deverão seguir o padrão URL encoding.
 
 ===== PADRÃO QR CODE LEGADO =====
 0 - X_
 1 - PAY_
 2 - transactionId_
 3 - amount_
 4 - merchantName_
 5 - cnpj_
 6 - CPN_
 7 - campaignId_
 8 - parcelas_
 9 - paymodes_
 10 - bandeiras_
 11 - merchantKeyId_
 12 - blobOfflinePayment
 */


-(Transaction *)parseToTransaction:(NSString *)contentQrCode{
    Transaction *transactionInfo = [Transaction new];
    Merchant *merchant = [Merchant new];
    
    //Split into dictionary from Legacy or Fintechs model
    NSMutableDictionary *paymentDictionary = [self generateDictionaryFromQRContent:contentQrCode];
    
    //PARSE FINTECH'S QR CODE
    if ([[paymentDictionary valueForKey:@"fintechModel"] boolValue] == YES) {
        [transactionInfo setAmount:[paymentDictionary valueForKey:@"e"]];
        if ([paymentDictionary valueForKey:@"g"] != nil){
            [transactionInfo setInstallments:[paymentDictionary valueForKey:@"g"]];
        }else{
            [transactionInfo setInstallments:@"1"];
        }
        
        [transactionInfo setType:[paymentDictionary valueForKey:@"c"]];
        
        if ([[[transactionInfo type] uppercaseString] isEqualToString:@"PAY_ONLINE"]){
            NSAssert([paymentDictionary valueForKey:@"d"] != nil,
                     @"LIB4ALL: Transaction id ausente em transação ONLINE.");
        }else{
            [transactionInfo setBlob:[paymentDictionary valueForKey:@"k"]];
            [merchant setMerchantKeyId:[paymentDictionary valueForKey:@"l"]];
        }
        
        [transactionInfo setTransactionID:[paymentDictionary valueForKey:@"d"]];
        
        [transactionInfo setAcceptedModes:[paymentDictionary valueForKey:@"h"]];
        [transactionInfo setAcceptedBrands:[paymentDictionary valueForKey:@"i"]];
        
        [merchant setName:[paymentDictionary valueForKey:@"f"]];
        [merchant setCpfOrCnpj:[paymentDictionary valueForKey:@"g"]];
        [transactionInfo setIsCancellation:[[paymentDictionary valueForKey:@"cancellation"] boolValue]];
    
        if([paymentDictionary valueForKey:@"m"]) {
            [transactionInfo setAcceptsPromoCodes:[[paymentDictionary valueForKey:@"m"] isEqualToString:@"T"]];
        } else {
            [transactionInfo setAcceptsPromoCodes:NO];
        }
        
        if([paymentDictionary valueForKey:@"j"]) {
            [transactionInfo setAcceptsOfflinePayment:[[paymentDictionary valueForKey:@"j"] isEqualToString:@"T"]];
        } else {
            [transactionInfo setAcceptsOfflinePayment:NO];
        }
        
    }else{ //PARSE LEGACY'S QR CODE
        
        [transactionInfo setAmount:[NSNumber numberWithDouble:[[paymentDictionary valueForKey:@"amount"] doubleValue]]];
        [transactionInfo setTransactionID:[paymentDictionary valueForKey:@"transactionId"]];
        [merchant setName:[paymentDictionary valueForKey:@"merchantName"]];
        [merchant setCpfOrCnpj:[paymentDictionary valueForKey:@"cnpj"]];
        [transactionInfo setIsCancellation:[[paymentDictionary valueForKey:@"cancellation"] boolValue]];
        [transactionInfo setAcceptsPromoCodes:NO];
        
        //Atribui somente se for pagamento e não cancelamento
        if (transactionInfo.isCancellation == false) {
            [transactionInfo setAcceptedModes:[paymentDictionary valueForKey:@"paymodes"]];
            [transactionInfo setAcceptedBrands:[paymentDictionary valueForKey:@"brands"]];
            [transactionInfo setBlob:[paymentDictionary valueForKey:@"blob"]];
            [merchant setMerchantKeyId:[paymentDictionary valueForKey:@"merchantKeyId"]];
            [transactionInfo setInstallments:[paymentDictionary valueForKey:@"parcels"]];
        }
        
        
    }
    
    [transactionInfo setMerchant:merchant];
    
    return transactionInfo;
}

@end
