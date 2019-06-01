//
//  FamilyMonthDayViewController.m
//  Example
//
//  Created by Adriano Soares on 31/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyMonthDayViewController.h"
#import "BaseNavigationController.h"
#import "Services.h"
#import "LoadingViewController.h"
#import "LayoutManager.h"

@interface FamilyMonthDayViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property int selectedDay;

@end

@implementation FamilyMonthDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    _selectedDay = -1;
    
    [self configureLayout];
    
    self.serverKey = @"recurrenceDay";
    
    if (self.data) {
        self.currentValueLabel.text = self.data;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) serverFormattedData:(int) data {
    return [NSString stringWithFormat:@"%d", (data+1)];
}

- (BOOL) isValidData {
    return _selectedDay >= 0;
}


- (void) saveData:(UIViewController *)vc data:(NSString *)data withCompletion: (void (^)(NSString *))completion {
    Services *service = [[Services alloc] init];
    
    LoadingViewController *loader = [[LoadingViewController alloc] init];
    
    service.failureCase = ^(NSString *cod, NSString *msg){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [loader finishLoading:^{
            [vc presentViewController:alert animated:YES completion:nil];
        }];
        
    };
    
    service.successCase = ^(NSDictionary *response) {
        [loader finishLoading:^{
            if (completion) {
                completion(data);
            }
        }];
        
    };
    
    if (_cardId && _customerId) {
        if (data != nil) {
            NSDictionary *dict = @{
                                   self.serverKey: [NSNumber numberWithInteger:[data integerValue]]
                                   };
            [service updateSharedCard:self.cardId customerId:self.customerId withData:dict];
            
            [loader startLoading:vc title:@"Aguarde..."];
        }
    }
}

- (IBAction)cancelButton:(id)sender {
}


- (IBAction)saveButton:(id)sender {
    if ([self isValidData]) {
        NSString *formattedData = [self serverFormattedData:self.selectedDay];
        if (self.isCreation) {
            if (self.completion) {
                self.completion(formattedData);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self saveData:self
                      data:formattedData
            withCompletion:^(NSString *data) {
                if (self.completion) {
                    self.completion(data);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }
    
    }

}

- (void) configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    
    LayoutManager *LM = [LayoutManager sharedManager];
    
    self.navigationItem.title = @"Definir dia de restabelecimento";
    self.currentLabel.text    = @"Dia do restabelecimento do limite atual";
    self.titleLabel.text      = @"Selecione um novo dia para o restabelecimento do limite";
    self.titleLabel.numberOfLines = 2;
    
    /*
     if (self.data) {
     self.currentValueLabel.text = [self.dataFieldProtocol currentValueFormatted:self.data];
     } else {
     self.currentValueLabel.text = @"Indefinido";
     }
     */
    self.view.backgroundColor = LM.backgroundColor;
    
    self.currentLabel.font = [LM fontWithSize:LM.regularFontSize];
    self.currentLabel.textColor = LM.darkFontColor;
    
    self.currentValueLabel.font = [LM fontWithSize:LM.regularFontSize];
    self.currentValueLabel.textColor = LM.primaryColor;
    
    self.titleLabel.font = [LM fontWithSize:LM.regularFontSize];
    self.titleLabel.textColor = LM.darkFontColor;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 31;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dayCell" forIndexPath:indexPath];
    LayoutManager *LM = [LayoutManager sharedManager];
    
    UIView  *view  = [cell viewWithTag:1];
    if (indexPath.row == _selectedDay) {
        view.layer.borderColor = [[LM primaryColor] CGColor];
        view.layer.borderWidth = 2;
        view.layer.cornerRadius = view.bounds.size.width/2;
    } else {
        view.layer.borderWidth = 0;
    }
    
    UILabel *label = [cell viewWithTag:2];
    
    label.text = [NSString stringWithFormat:@"%ld", (indexPath.row+1)];
    label.font = [LM fontWithSize:LM.regularFontSize];
    label.textColor = LM.darkFontColor;
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width/7.5;
    return CGSizeMake(width, width);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedDay = (int)indexPath.row;
    
    [self.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
