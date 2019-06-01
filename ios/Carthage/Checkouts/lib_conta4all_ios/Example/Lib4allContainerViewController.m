//
//  Lib4allContainerViewController.m
//  Example
//
//  Created by 4all on 5/4/16.
//  Copyright © 2016 4all. All rights reserved.
//

#import "Lib4allContainerViewController.h"

@interface Lib4allContainerViewController ()

@end

@implementation Lib4allContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetComponentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resetComponentView{
    if (self.vc != nil) {
        [self.vc removeFromParentViewController];
    }
    
    ComponentViewController *vc = [[ComponentViewController alloc] init];
    
    //Set delegate para callbacks pre e pós venda
    vc.delegate = self;
    
    //Define o titulo do botão do componente
    vc.buttonTitleWhenNotLogged = @"ENTRAR";
    
    //Define o titulo do botão após estar logado
    vc.buttonTitleWhenLogged = @"FAZER RECARGA";
    
    //Define o tamanho que o componente deverá ter em tela de acordo com o container.
    vc.view.frame = self.view.bounds;
    
    //Adiciona view do component ao controller
    [self.view addSubview:vc.view];
    
    //Adiciona a parte funcional ao container
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
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
