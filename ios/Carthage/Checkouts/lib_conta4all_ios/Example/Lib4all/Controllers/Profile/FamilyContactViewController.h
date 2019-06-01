//
//  FamilyContactViewController.h
//  Example
//
//  Created by Adriano Soares on 15/12/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import <AddressBook/ABPerson.h>

@interface FamilyContactViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, CNContactPickerDelegate, UITextFieldDelegate>

@end
