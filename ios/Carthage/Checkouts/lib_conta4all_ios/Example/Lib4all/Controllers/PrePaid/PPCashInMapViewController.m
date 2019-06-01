//
//  PPCashInMapViewController.m
//  Example
//
//  Created by Gabriel Miranda Silveira on 06/12/17.
//  Copyright © 2017 4all. All rights reserved.
//

#import "PPCashInMapViewController.h"
#import "LayoutManager.h"
#import "CashInMapAnnotation.h"
#import "CashInMapAnnotationView.h"
#import "BaseNavigationController.h"

@interface PPCashInMapViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation PPCashInMapViewController

static NSString* const kNavigationTitle = @"Adicionar dinheiro";
static double const kIguatemiLatitude = -30.0210876;
static double const kIguatemiLongitude = -51.1638628;

-(void)viewDidLoad {
    [super viewDidLoad];
    _mapView.delegate = self;
    [self configureLayout];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureLayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [((BaseNavigationController *) self.navigationController) configureLayout];
    
    self.navigationItem.title = @"";
}


- (void)configureLayout{
    self.navigationItem.title = kNavigationTitle;
}

- (void)setMap {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kIguatemiLatitude, kIguatemiLongitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 700, 700);
    CashInMapAnnotation *annotation = [[CashInMapAnnotation alloc] initWithCoordinate:coordinate];
    [_mapView addAnnotation:annotation];
    [_mapView setRegion:region animated:YES];
    [_mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    [self setMap];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:@"annotation"];
    if(annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    } else {
        annotationView.annotation = annotation;
    }
    annotationView.image = [UIImage lib4allImageNamed:@"icon-position"];
    annotationView.canShowCallout = NO;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    for (UIView *subview in view.subviews){
        if(subview.tag == 1) {
            [subview removeFromSuperview];
            return;
        }
    }
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(-97, -120, 400, 400)];
    calloutView.tag = 1;
    [calloutView addSubview:[[[NSBundle getLibBundle] loadNibNamed:@"PPCashInMapAnnotationDialogView" owner:self options:nil] objectAtIndex:0]];
    [view addSubview:calloutView];
}

@end
