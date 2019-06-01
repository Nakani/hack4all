//
//  FamilyWeekDayTableViewController.m
//  Example
//
//  Created by Adriano Soares on 25/01/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyWeekDayTableViewController.h"
#import "BaseNavigationController.h"
#import "MainActionButton.h"

#import "UIImage+Color.h"
#import "LayoutManager.h"
#import "DateUtil.h"

#import "LoadingViewController.h"
#import "Services.h"


@interface FamilyWeekDayTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *floatingBottomView;

@property (strong, nonatomic) NSArray *dayLabels;
@property (strong, nonatomic) NSMutableArray *values;

@property (weak, nonatomic) IBOutlet MainActionButton *saveButton;
@end

@implementation FamilyWeekDayTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serverKey = @"weekdays";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dayLabels = @[
        @"Domingo",
        @"Segunda-feira",
        @"Terça-feira",
        @"Quarta-feira",
        @"Quinta-feira",
        @"Sexta-feira",
        @"Sábado"
    ];
    
    self.serverKey = @"weekdays";
    
    if (self.data) {
        [self loadData];
    } else {
        self.values = [@[@YES, @YES, @YES, @YES, @YES, @YES, @YES] mutableCopy];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configureLayout];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self moveFloatingViews];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self moveFloatingViews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadData {
    NSMutableArray *days = [@[@NO, @NO, @NO, @NO, @NO, @NO, @NO] mutableCopy];
    for (int i = 0; i < self.data.count; i++) {
        int index = [self.data[i] intValue];
        days[index] = @YES;
    }
    self.values = days;
}

- (NSArray *)serverFormattedData:(NSArray *) data {
    NSMutableArray *days = [[NSMutableArray alloc] init];
    for (int i = 0; i < data.count; i++ ) {
        if ([data[i] boolValue]) {
            [days addObject:[NSNumber numberWithInt:i]];
        }
    }
    return days;
}

- (BOOL) isValid:(NSArray *) data {
    BOOL valid = NO;
    for (int i = 0; i < data.count; i++ ) {
        valid = valid || [self.values[i] boolValue];
    }
    
    return valid;
}

- (void) saveData:(UIViewController *)vc data:(NSArray *)data withCompletion: (void (^)(NSArray *))completion {
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
                                   self.serverKey: data
                                   };
            [service updateSharedCard:self.cardId customerId:self.customerId withData:dict];
            
            [loader startLoading:vc title:@"Aguarde..."];
        }

    }
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButton:(id)sender {
    if ([self isValid:self.values]) {
        NSArray *formattedData = [self serverFormattedData:self.values];
        if (self.isCreation) {
            if (self.completion && formattedData) {
                self.completion(formattedData);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if (formattedData) {
                [self saveData:self
                          data:formattedData
                withCompletion:^(NSArray *data) {
                    if (self.completion && formattedData) {
                        self.completion(data);
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            
            }


        }
    } else {
        NSString *msg = @"É necessario escolher no minimo um dia.";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        

        [self presentViewController:alert animated:YES completion:nil];

    
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dayLabels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekDayCell" forIndexPath:indexPath];
    if (cell) {
        LayoutManager *LM = [LayoutManager sharedManager];
        
        UILabel *label = [cell viewWithTag:1];
        label.text = self.dayLabels[indexPath.row];
        label.font = [LM fontWithSize: LM.regularFontSize];
        label.textColor = [LM darkFontColor];
        
        UIImageView *checkmark = [cell viewWithTag:2];
        if ([self.values[indexPath.row] boolValue]) {
            [checkmark setHidden:NO];
        } else {
            [checkmark setHidden:YES];
        }
        
        UIView *viewCard = (UIView *)[cell viewWithTag:3];
        viewCard.layer.cornerRadius        = 5;
        viewCard.layer.shadowOffset        = CGSizeMake(0, 1);
        viewCard.layer.shadowRadius        = 2;
        viewCard.layer.shadowColor         = [LM darkGray].CGColor;
        viewCard.layer.shadowOpacity       = 0.5;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChecked = [self.values[indexPath.row] boolValue];
    self.values[indexPath.row] = [NSNumber numberWithBool:!isChecked];
    
    if ([self isValid:self.values]) {
        [_saveButton setEnabled:YES];
    } else {
        [_saveButton setEnabled:NO];
    }
    
    [UIView animateWithDuration:0 animations:^{
        [tableView reloadData];
    } completion:^(BOOL finished) {
        [self moveFloatingViews];
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self moveFloatingViews];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell"];
    LayoutManager *LM = [LayoutManager sharedManager];
    cell.backgroundColor = LM.backgroundColor;
    
    UILabel *currentLabel = [cell viewWithTag:1];
    currentLabel.font = [LM fontWithSize:LM.regularFontSize];
    currentLabel.textColor = LM.darkFontColor;
    currentLabel.text = @"Dias da semana atual";
    
    UILabel *currentValueLabel = [cell viewWithTag:2];
    currentValueLabel.font = [LM fontWithSize:LM.regularFontSize];
    currentValueLabel.textColor = LM.primaryColor;
    currentValueLabel.text = [DateUtil convertWeekDays:self.data];
    
    
    
    UILabel *titleLabel = [cell viewWithTag:3];
    titleLabel.font = [LM fontWithSize:LM.regularFontSize];
    titleLabel.textColor = LM.darkFontColor;
    titleLabel.text = @"Selecione os novos dias da semana";
    
    
    
    return cell;
}

- (void) moveFloatingViews {
    CGRect bottomFrame = self.floatingBottomView.frame;
    bottomFrame.origin.y = self.tableView.contentOffset.y + self.tableView.frame.size.height - self.floatingBottomView.frame.size.height;
    self.floatingBottomView.frame = bottomFrame;
    
    [self.view bringSubviewToFront:self.floatingBottomView];
}

- (void) configureLayout {
    BaseNavigationController *navigationController = (BaseNavigationController *)self.navigationController;
    [navigationController configureLayout];
    self.navigationItem.title = @"Definir dias da semana";
    
    LayoutManager *LM = [LayoutManager sharedManager];
    self.view.backgroundColor = LM.backgroundColor;
    self.floatingBottomView.backgroundColor = LM.backgroundColor;

}

@end
