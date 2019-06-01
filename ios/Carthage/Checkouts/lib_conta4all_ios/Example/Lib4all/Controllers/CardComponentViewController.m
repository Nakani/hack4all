//
//  CardComponentViewController.m
//  Example
//
//  Created by Cristiano Matte on 20/07/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "CardComponentViewController.h"
#import "LayoutManager.h"
#import "Lib4all.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "CreditCardsList.h"
#import "UIImageView+WebCache.h"

@interface CardComponentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *cardBrandImageView;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeCardButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, copy) NSString *cardId;
@property BOOL invisibleBackground;
@end

@implementation CardComponentViewController

- (id)initWithCardId:(NSString *)cardId {
    self = [self initWithCardId:cardId andInvisibleBackground:false];
    return self;
}

- (id)initWithCardId:(NSString *)cardId andInvisibleBackground:(BOOL)invisible {
    self =  [[UIStoryboard storyboardWithName:@"Lib4all" bundle: [NSBundle getLibBundle]] instantiateViewControllerWithIdentifier:@"CardComponentViewController"];
    
    if (self) {
        self.cardId = cardId;
    }
    self.invisibleBackground = invisible;
    return self;
}

- (void)changeCardId:(NSString *)cardId {
    self.cardId = cardId;
    [self getCardDetails];
}

#pragma mark - View controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    LayoutManager *layout = [LayoutManager sharedManager];
    
    //Button 'Alterar'
    self.changeCardButton.userInteractionEnabled = YES;
    [self.changeCardButton.titleLabel setFont:[[LayoutManager sharedManager] fontWithSize:layout.regularFontSize]];
    [self.changeCardButton setTitleColor:[[LayoutManager sharedManager] primaryColor] forState:UIControlStateNormal];
    
    //Labels
    self.cardNumberLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.regularFontSize];
    self.cardTypeLabel.font = [[LayoutManager sharedManager] fontWithSize:layout.midFontSize];
    self.cardNumberLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    self.cardTypeLabel.textColor = [[LayoutManager sharedManager] darkFontColor];
    if (_invisibleBackground) {
        self.containerView.backgroundColor = [UIColor clearColor];
    }
    [self getCardDetails];
}

#pragma mark - Actions
- (IBAction)changeCardButtonTouched {
    [[[Lib4all alloc] init] showCardPickerInViewController:self.parentViewController completionBlock:^(NSString *cardID) {
        
        // Altera o cartão padrão no servidor (best effort)
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg){ };
        service.successCase = ^(NSDictionary *response){ };
        
        [service setDefaultCardWithCardID:cardID];
        
        if (self.didSelectCardCompletionBlock != nil) {
            self.didSelectCardCompletionBlock(cardID);
        }
    }];
}

- (void)getCardDetails {
    /*
     * Se o cartão selecionado está salvo localmente, recupera os dados locais.
     * Caso contrário, obtém os dados do servidor.
     */
    CreditCard *card = [[CreditCardsList sharedList] getCardWithID:_cardId];
    
    if (card != nil) {
        [self.cardBrandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]]
                                                 placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
        
        self.cardNumberLabel.text = [card getMaskedPan];
        self.cardTypeLabel.text = card.cardDescription;
    } else {
        Services *service = [[Services alloc] init];
        
        service.failureCase = ^(NSString *cod, NSString *msg){
            
        };
        
        service.successCase = ^(NSDictionary *response){
            CreditCard *card = [[CreditCard alloc] init];
            card.brandId = response[BrandIDKey];
            card.lastDigits = response[LastDigitsKey];
            card.type = [response[CardTypeKey] integerValue];
            card.brandLogoUrl = response[CardBrandLogoUrlKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cardBrandImageView.hidden = NO;
                self.cardNumberLabel.hidden = NO;
                self.changeCardButton.hidden = NO;
                self.cardTypeLabel.hidden = NO;
                [self.cardBrandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.png", card.brandLogoUrl]]
                                           placeholderImage:[UIImage lib4allImageNamed:@"icone_cartao.png"]];
                self.cardNumberLabel.text = [card getMaskedPan];
                self.cardTypeLabel.text = [card cardDescription];
            });
        };
        
        self.cardBrandImageView.hidden = YES;
        self.cardNumberLabel.hidden = YES;
        self.cardTypeLabel.hidden = YES;
        self.changeCardButton.hidden = YES;
        [service getCardDetailsWithCardID:self.cardId];
    }
}

//-(void)setCardTypeWithCard:(CreditCard*)card {
//    NSString *cardType;
//    
//    switch (card.type) {
//        case CardTypeDebit:
//            cardType = @"DÉBITO";
//            break;
//        case CardTypeCredit:
//            cardType = @"CRÉDITO";
//            break;
//        case CardTypeCreditAndDebit:
//            cardType = @"CRÉDITO E DÉBITO";
//            break;
//        default:
//            //VALIDAR COM UX:
//            cardType = @"Tipo de cartão não reconhecido";
//    }
//    
//    self.cardTypeLabel.text = cardType;
//}


@end
