//
//  UserDataTableViewController.m
//  Example
//
//  Created by 4all on 5/27/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "UserDataViewController.h"
#import "LayoutManager.h"
#import "User.h"
#import "BaseNavigationController.h"
#import "NSStringMask.h"
#import "Services.h"
#import "ServicesConstants.h"
#import "ChangePhoneNumberViewController.h"
#import "ChangeEmailAddressViewController.h"
#import "ChangeNameViewController.h"
#import "LoadingViewController.h"
#import "UIFloatLabelTextField.h"
#import "UIFloatLabelTextField+Border.h"
#import "UITextFieldMask.h"
#import "NSString+Mask.h"
#import "NSString+NumberArray.h"
#import "CpfCnpjUtil.h"
#import "DateUtil.h"
#import "UIImage+Color.h"
#import "Services.h"
#import "UIImage+Size.h"
#import "AnalyticsUtil.h"

@interface UserDataViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIFloatLabelTextField *phoneTextField;
@property (strong, nonatomic) UIFloatLabelTextField *emailTextField;
@property (strong, nonatomic) UIFloatLabelTextField *fullNameTextField;
@property (strong, nonatomic) UIFloatLabelTextField *cpfTextField;
@property (strong, nonatomic) UIFloatLabelTextField *birthdateTextField;
@property (strong, nonatomic) UIFloatLabelTextField *employerTextField;
@property (strong, nonatomic) UIFloatLabelTextField *jobPositionTextField;
@property (weak, nonatomic) IBOutlet UIView *shadowRoundView;
@property (weak, nonatomic) IBOutlet UIImageView *roundedPictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconAddPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *personNameWelcome;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (strong, nonatomic) NSMutableArray *activeFields;

@end

@implementation UserDataViewController


static NSString* const kNavigationTitle = @"Perfil";

// MARK: - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    
    self.roundedPictureImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressAddPicture)];
    [self.roundedPictureImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self configureLayout];
    
    self.activeFields = [[NSMutableArray alloc] init];
    
    [self setData];
    
    // Atualiza os dados buscando no servidor
    Services *service = [[Services alloc] init];
    service.successCase = ^(NSDictionary *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setData];
        });
    };
     
    service.failureCase = ^(NSString *cod, NSString *msg){ };
    [service getAccountData:@[PhoneNumberKey, EmailAddressKey, CpfKey, FullNameKey, BirthdateKey, EmployerKey, JobPositionKey, TotpKey]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNavigationBar];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setData];
    [self configureNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_tableView setScrollEnabled:(_tableView.contentSize.height + 10 >= _tableView.frame.size.height)];
}

-(void) didPressAddPicture {
    
    [AnalyticsUtil logEventWithName:@"inserir_foto_perfil" andParameters:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Selecione" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Câmera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AnalyticsUtil logEventWithName:@"inserir_foto_perfil_camera" andParameters:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Galeria" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AnalyticsUtil logEventWithName:@"inserir_foto_perfil_galeria" andParameters:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
     
     [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) setData {
    User *user = [User sharedUser];
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    if(user.profilePictureBase64) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:user.profilePictureBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (imageData != nil) {
            self.roundedPictureImageView.image = [[UIImage alloc] initWithData:imageData];
        }
    }
    
    if (user.fullName) {
        NSString *firstName = [user.fullName componentsSeparatedByString:@" "][0];
        self.personNameWelcome.text = [NSString stringWithFormat:@"Olá, %@!", firstName];
        [fields addObject: @{ @"text": user.fullName,
                              @"editable": @YES,
                              @"protocol": [ChangeNameViewController class],
                              @"description":@"Nome"}];
    } else {
        self.personNameWelcome.text = @"Olá!";
    }
    
    if (user.phoneNumber) {
        NSString* phone = [user.phoneNumber substringFromIndex:2];
        phone = [NSStringMask maskString:phone withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
        
        [fields addObject: @{ @"text": phone,
                              @"editable": @YES,
                              @"protocol": [ChangePhoneNumberViewController class],
                              @"description":@"Telefone"}];
        
    }
    if (user.emailAddress) {
        [fields addObject: @{ @"text": user.emailAddress,
                              @"editable": @YES,
                              @"protocol": [ChangeEmailAddressViewController class],
                              @"description":@"E-mail"}];
    }
    
    if (user.cpf) {
        NSString *mask;
        if (user.cpf.length <= 11) {
            mask = @"###.###.###-##";
        } else {
            mask = @"##.###.###/####-##";
        }
        
        [fields addObject: @{ @"text": [user.cpf stringByApplyingMask:mask maskCharacter:'#'],
                              @"editable": @NO,
                              @"description":@"CPF"}];
    }
    
    if (user.birthdate) {
        NSString *text = [DateUtil convertDateString:user.birthdate fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
        [fields addObject: @{ @"text": text,
                              @"editable": @NO,
                              @"description":@"Data de nascimento"}];
    
    }

    if (user.employer) {
        [fields addObject: @{ @"text": user.employer,
                              @"editable": @NO }];
    }

    if (user.jobPosition) {
        [fields addObject: @{ @"text": user.jobPosition,
                              @"editable": @NO }];
    
    }
    
    self.activeFields = fields;
    [self.tableView reloadData];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];
    LayoutManager *layout = [LayoutManager sharedManager];
    
    UILabel *label  = [cell viewWithTag:1];
    label.text      = [self.activeFields[indexPath.row] valueForKey:@"text"];
    label.font      = [layout fontWithSize:layout.subTitleFontSize];
    label.textColor = layout.darkFontColor;
    
    BOOL isEditable = [[self.activeFields[indexPath.row] valueForKey:@"editable"] boolValue];
    UIImageView *disclosure = [cell viewWithTag:2];
    disclosure.image = [disclosure.image withColor:layout.primaryColor];
    [disclosure setHidden:YES];
    
    if (isEditable) {
        [disclosure setHidden:NO];
    } else {
        cell.contentView.alpha = 0.5;
    }
    
    UILabel *description = [cell viewWithTag:3];
    description.text = [self.activeFields[indexPath.row] valueForKey:@"description"];
    description.font = [layout boldFontWithSize:layout.midFontSize];
    description.textColor = layout.darkFontColor;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activeFields.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isEditable = [[self.activeFields[indexPath.row] valueForKey:@"editable"] boolValue];
    if (isEditable) {
        Class protocol = [self.activeFields[indexPath.row] valueForKey:@"protocol"];
        if (protocol == [ChangeEmailAddressViewController class]) {
            [AnalyticsUtil logEventWithName:@"edicao_email_usuario" andParameters:nil];
            
            if (self.isIndependentOfFlow) {
                [self makeIndependentNavigationPushViewControllerWithIdentifier:@"ChangeEmailAddressViewController"];
            } else {
                [self performSegueWithIdentifier:@"ChangeEmailAddressSegue" sender:nil];
            }
            return;
        }
        if (protocol == [ChangePhoneNumberViewController class]) {
            [AnalyticsUtil logEventWithName:@"edicao_telefone_usuario" andParameters:nil];
            
            if (self.isIndependentOfFlow) {
                [self makeIndependentNavigationPushViewControllerWithIdentifier:@"ChangePhoneNumberViewController"];
            } else {
                [self performSegueWithIdentifier:@"ChangePhoneNumberSegue" sender:nil];
            }
            return;
        }
        if (protocol == [ChangeNameViewController class]) {
            [AnalyticsUtil logEventWithName:@"edicao_nome_usuario" andParameters:nil];
            
            if (self.isIndependentOfFlow) {
                [self makeIndependentNavigationPushViewControllerWithIdentifier:@"ChangeNameViewController"];
            } else {
                [self performSegueWithIdentifier:@"ChangeNameSegue" sender:nil];
            }
            return;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;
}


// MARK: - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    User *user = [User sharedUser];
    if ([segue.identifier isEqualToString:@"ChangePhoneNumberSegue"]) {
        ChangePhoneNumberViewController *viewController = (ChangePhoneNumberViewController *)segue.destinationViewController;
        if (user.phoneNumber) {
            NSString *phone = [user.phoneNumber substringFromIndex:2];
            phone = [NSStringMask maskString:phone withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
            viewController.currentPhoneNumber = phone;
        }
    } else if ([segue.identifier isEqualToString:@"ChangeEmailAddressSegue"]) {
        ChangeEmailAddressViewController *viewController = (ChangeEmailAddressViewController *)segue.destinationViewController;
        viewController.currentEmailAddress = user.emailAddress;
    } else if ([segue.identifier isEqualToString:@"ChangeNameSegue"]) {
    
    }
}

// Este método é usado somente em apps que setarem a flag isIndependentOfFlow = true
// Ele empilha as telas a seguir na navigationController que o app hospedeiro passar por parametro
- (void)makeIndependentNavigationPushViewControllerWithIdentifier:(NSString *)identifier {
    User *user = [User sharedUser];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Lib4all" bundle:[NSBundle getLibBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    if ([identifier isEqualToString:@"ChangePhoneNumberViewController"]) {
        if (user.phoneNumber) {
            NSString *phone = [user.phoneNumber substringFromIndex:2];
            phone = [NSStringMask maskString:phone withPattern:@"\\((\\d{2})\\) (\\d{5})-(\\d{4})"];
            ((ChangePhoneNumberViewController *) viewController).currentPhoneNumber = phone;
        }
    } else if ([identifier isEqualToString:@"ChangeEmailAddressViewController"]) {
        ((ChangeEmailAddressViewController *) viewController).currentEmailAddress = user.emailAddress;
    } else if ([identifier isEqualToString:@"ChangeNameViewController"]) {
        
    }
    [self.independentNavigation pushViewController:viewController animated:YES];
}

- (void)didPressCloseButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Layout

- (void)configureLayout {
    
    LayoutManager *layout = [LayoutManager sharedManager] ;

    self.view.backgroundColor = layout.backgroundColor;

    self.roundedPictureImageView.image = [self.roundedPictureImageView.image withColor:layout.primaryColor];
    self.iconAddPictureImageView.image = [self.iconAddPictureImageView.image withColor:layout.primaryColor];
    
    self.roundedPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.roundedPictureImageView.layer.cornerRadius = self.roundedPictureImageView.frame.size.height / 2;
    self.roundedPictureImageView.clipsToBounds = YES;
    
    [self.shadowRoundView layoutIfNeeded];
    UIColor *whiteHalfTransparent = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.5];
    self.shadowRoundView.backgroundColor = whiteHalfTransparent;
    self.shadowRoundView.layer.cornerRadius = self.shadowRoundView.frame.size.height / 2;
    
    self.personNameWelcome.font = [layout boldFontWithSize:layout.subTitleFontSize];
    self.personNameWelcome.textColor = layout.darkFontColor;
    
    // Isso é pra arrumar a view quando for apresentada independente
    if (self.isIndependentOfFlow) {
        self.topConstraint.constant = -110;
    }
}

- (void) configureNavigationBar {
    self.navigationItem.title = kNavigationTitle;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    if(self.navigationController.viewControllers[0] == self && !self.isIndependentOfFlow) {
        UIImage *closeButtonImage = [UIImage lib4allImageNamed:@"x"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[closeButtonImage withColor:[LayoutManager sharedManager].lightFontColor]  style:UIBarButtonItemStylePlain target:self action:@selector(didPressCloseButton)];
    }
}

// MARK: - ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *jpegDataImage = UIImageJPEGRepresentation(chosenImage, 0.5);
    
    NSString *base64ImageString = [jpegDataImage base64EncodedStringWithOptions:0];
    Services *services = [[Services alloc] init];
    
    services.successCase = ^(id response) {
        [User sharedUser].profilePictureBase64 = base64ImageString;
        self.roundedPictureImageView.image = chosenImage;
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    services.failureCase = ^(NSString *errorID, NSString *errorMessage) {
        [picker dismissViewControllerAnimated:YES completion:^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Atenção!"
                                                                           message:errorMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }];
    };
    
    [services setAccountPhoto:base64ImageString];
}

@end
