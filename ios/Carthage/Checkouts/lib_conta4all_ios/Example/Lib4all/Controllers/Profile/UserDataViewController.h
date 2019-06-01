//
//  UserDataTableViewController.h
//  Example
//
//  Created by 4all on 5/27/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// Propriedades adicionadas para que esta classe possa ser exportada
//  por uma função que passa somente a sua referencia.
// Assim o app hospedeiro pode apresentar esta tela do jeito que quiser
// e controlar o flux a partir de sua própria navigationController
@property BOOL isIndependentOfFlow;
@property UINavigationController *independentNavigation;

@end
