//
//  SubscriptionDetailsView.m
//  Example
//
//  Created by Cristiano Matte on 04/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "SubscriptionDetailsView.h"
#import "LayoutManager.h"

@interface SubscriptionDetailsView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *amountLabel;

@end

@implementation SubscriptionDetailsView

@synthesize title = _title;

- (instancetype)initWithValues:(NSArray *)values {
    self = [super init];
    
    if (self) {
        self.values = values;
        self.titleLabel = [[UILabel alloc] init];
        self.dateLabel = [[UILabel alloc] init];
        self.amountLabel = [[UILabel alloc] init];
        [self configureLayout];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)configureLayout {
    // A view aparece apenas quando há valores a serem exibidos
    if (self.values == nil) {
        return;
    }
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    LayoutManager *layoutManager = [LayoutManager sharedManager];
    
    // Configura a label de título da view
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = [layoutManager boldFontWithSize:15.0];
    self.titleLabel.textColor = [layoutManager darkerGray];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // Adiciona as constraints de título da view
    [self addSubview:self.titleLabel];
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleLabel]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"titleLabel":self.titleLabel}]];
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleLabel]-0-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"titleLabel":self.titleLabel}]];
    
    // Adiciona os cabeçalhos de data e valor
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateLabel.font = [layoutManager fontWithSize:15.0];
    self.dateLabel.textColor = [layoutManager darkerGray];
    self.dateLabel.text = @"Data";
    
    self.amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.amountLabel.font = [layoutManager fontWithSize:15.0];
    self.amountLabel.textColor = [layoutManager darkerGray];
    self.amountLabel.text = @"Valor";
    
    // Adiciona as constraints dos cabeçalhos de data e valor
    [self addSubview:self.dateLabel];
    [self addSubview:self.amountLabel];
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel]-10-[dateLabel]"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"titleLabel":self.titleLabel,
                                                                                        @"dateLabel":self.dateLabel}]];
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[dateLabel]-<=8-[amountLabel]-0-|"
                                                                              options:NSLayoutFormatAlignAllCenterY
                                                                              metrics:nil
                                                                                views:@{@"dateLabel":self.dateLabel,
                                                                                        @"amountLabel":self.amountLabel}]];
    
    // Cria os formatadores de data e moeda
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = numberFormatter.minimumFractionDigits = 2;
    
    // Adiciona cada conjunto de data e valor do array na view
    UIView *lastView = self.dateLabel;
    for (NSDictionary *dictionary in self.values) {
        UILabel *dateLabel = [[UILabel alloc] init];
        UILabel *currencyLabel = [[UILabel alloc] init];
        UILabel *amountLabel = [[UILabel alloc] init];
        
        // Configura a label de data
        dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        dateLabel.font = [layoutManager fontWithSize:15.0];
        dateLabel.textColor = [layoutManager darkerGray];
        dateLabel.text = [dateFormatter stringFromDate:dictionary[@"date"]];
        
        // Configura a label de valor
        amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        amountLabel.font = [layoutManager fontWithSize:15.0];
        amountLabel.textColor = [layoutManager darkerGray];
        amountLabel.text = [numberFormatter stringFromNumber:dictionary[@"amount"]];
        
        // Configura a label de R$
        currencyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        currencyLabel.font = [layoutManager fontWithSize:10.0];
        currencyLabel.textColor = [layoutManager darkerGray];
        currencyLabel.text = @"R$";
        
        // Adiciona as constraints das labels de data, R$ e valor
        [self addSubview:dateLabel];
        [self addSubview:currencyLabel];
        [self addSubview:amountLabel];
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-10-[dateLabel]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"lastView":lastView,
                                                                                            @"dateLabel":dateLabel}]];
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[dateLabel]-<=8-[currencyLabel]-1-[amountLabel]-0-|"
                                                                                  options:NSLayoutFormatAlignAllBaseline
                                                                                  metrics:nil
                                                                                    views:@{@"dateLabel":dateLabel,
                                                                                            @"currencyLabel":currencyLabel,
                                                                                            @"amountLabel":amountLabel}]];
        // A lastView é sempre a view mais abaixo da tela
        lastView = dateLabel;
    }
    
    // Adiciona a constraint que liga a view mais abaixo da tela ao fim da view
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]-0-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"lastView":lastView}]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
