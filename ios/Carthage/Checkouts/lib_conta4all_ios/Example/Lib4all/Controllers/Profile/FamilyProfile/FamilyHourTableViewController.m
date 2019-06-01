//
//  FamilyHourTableViewController.m
//  Example
//
//  Created by Adriano Soares on 01/02/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "FamilyHourTableViewController.h"
#import "BaseNavigationController.h"
#import "MainActionButton.h"

#import "UIButton+Color.h"
#import "LayoutManager.h"

#import "LoadingViewController.h"
#import "Services.h"

@interface FamilyHourTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *floatingBottomView;

@property (strong, nonatomic) NSArray *hourLabels;
@property (strong, nonatomic) NSMutableArray *values;

@property (weak, nonatomic) IBOutlet MainActionButton *saveButton;
@end

@implementation FamilyHourTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serverKey = @"schedules";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hourLabels = @[
        @"24h/dia",
        @"Manhã (6h01 às 12h)",
        @"Tarde (12h01 às 18h)",
        @"Noite (18h01 às 24h)",
        @"Madrugada (00h01 às 6h)"
    ];
    
    self.serverKey = @"schedules";
    
    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self configureLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView performWithoutAnimation:^{
        [self moveFloatingViews];
    }];
}

- (NSArray *)serverFormattedData:(NSArray *) data {
    
    NSMutableArray *hours = [[NSMutableArray alloc] init];
    if ([data[0] boolValue]) {
        NSDictionary *dict = @{
           @"start": @"00:00:00",
           @"end": @"23:59:59"
        };
        [hours addObject:dict];
        
    }
    if ([data[1] boolValue]) {
        NSDictionary *dict = @{
           @"start": @"6:01:00",
           @"end": @"12:00:59"
        };
        [hours addObject:dict];
        
    }
    if ([data[2] boolValue]) {
        NSDictionary *dict = @{
           @"start": @"12:01:00",
           @"end": @"18:00:59"
        };
        [hours addObject:dict];
    }
    if ([data[3] boolValue]) {
        NSDictionary *dict = @{
           @"start": @"18:01:00",
           @"end": @"23:59:59"
        };
        [hours addObject:dict];
        
    }
    if ([data[4] boolValue]) {
        NSDictionary *dict = @{
           @"start": @"00:00:00",
           @"end": @"6:00:59"
        };
        [hours addObject:dict];
    }
    return hours;
}

- (void) loadData {
    NSMutableArray *hours = [@[@NO, @NO, @NO, @NO, @NO]  mutableCopy];
    for (int i = 0; i < self.data.count; i++) {
        int index = [FamilyHourTableViewController scheduleToIndex:self.data[i]];
        if (index >= 0) {
            hours[index] = @YES;
        }
    }
    self.values = hours;
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
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _hourLabels.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hourCell" forIndexPath:indexPath];
    
    if (cell) {
        LayoutManager *LM = [LayoutManager sharedManager];
        
        UILabel *label = [cell viewWithTag:1];
        label.text = self.hourLabels[indexPath.row];
        label.font = [LM fontWithSize: LM.regularFontSize];
        label.textColor = [LM darkFontColor];
        
        UIImageView *checkmark = [cell viewWithTag:2];
        checkmark.hidden = ![self.values[indexPath.row] boolValue];
        /*
        if ([self.values[indexPath.row] boolValue]) {
            checkmark.image = [checkmark.image withColor:LM.lightGreen];
        } else {
            checkmark.image = [checkmark.image withColor:LM.lightGray];
        }
        */
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSSet *visibleSections = [NSSet setWithArray:[[tableView indexPathsForVisibleRows] valueForKey:@"section"]];
    if (visibleSections) {
        [self moveFloatingViews];
    }
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
        if (finished) {
            [self moveFloatingViews];
        }

    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView performWithoutAnimation:^{
        [self moveFloatingViews];
    }];
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
    currentLabel.text = @"Horário atual";
    
    UILabel *currentValueLabel = [cell viewWithTag:2];
    currentValueLabel.font = [LM fontWithSize:LM.regularFontSize];
    currentValueLabel.textColor = LM.primaryColor;
    currentValueLabel.text = [FamilyHourTableViewController schedulesToLabel:self.data];
    
    
    
    UILabel *titleLabel = [cell viewWithTag:3];
    titleLabel.font = [LM fontWithSize:LM.regularFontSize];
    titleLabel.textColor = LM.darkFontColor;
    titleLabel.text = @"Escolha entre as opções disponíveis";
    
    
    
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
    self.navigationItem.title = @"Editar horário";
    
    LayoutManager *LM = [LayoutManager sharedManager];
    self.view.backgroundColor = LM.backgroundColor;
    self.floatingBottomView.backgroundColor = LM.backgroundColor;
    

    
}

+ (int) scheduleToIndex: (NSDictionary *) schedule {
    NSString *start = [schedule valueForKey:@"start"];
    NSString *end   = [schedule valueForKey:@"end"];
    if ([start isEqualToString:@"00:00:00"] && [end isEqualToString:@"23:59:59"]) {
        return 0;
    } else if ([start isEqualToString:@"6:01:00"] && [end isEqualToString:@"12:00:59"]) {
        return 1;
    } else if ([start isEqualToString:@"12:01:00"] && [end isEqualToString:@"18:00:59"]) {
        return 2;
    } else if ([start isEqualToString:@"18:01:00"] && [end isEqualToString:@"23:59:59"]) {
        return 3;
    } else if ([start isEqualToString:@"00:00:00"] && [end isEqualToString:@"6:00:59"]) {
        return 4;
    } else {
        return -1;
    }
}

+ (NSString *) schedulesToLabel: (NSArray *) schedules {
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    BOOL custom = NO;
    BOOL full = NO;
    for (int i = 0; i < schedules.count; i++) {
        int index = [FamilyHourTableViewController scheduleToIndex:schedules[i]];
        if (index == 0) {
            full = YES;
        } else if (index < 0) {
            custom = YES;
        } else {
            NSString *label;
            switch (index) {
                case 1:
                    label = @"Manhã";
                    break;
                
                case 2:
                    label = @"Tarde";
                    break;
                case 3:
                    label = @"Noite";
                    break;
                case 4:
                    label = @"Madrugada";
                    break;
                    
                default:
                    label = @"";
                    break;
            }
            [labels addObject:label];
        }
        
        
    }
    if (labels.count >= 4 || full) {
        return @"24h";
    }
    if (custom) {
        return @"Horário personalizado";
    }

    return [labels componentsJoinedByString:@" - "];
}

@end
