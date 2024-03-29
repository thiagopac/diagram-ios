//
//  MTBAdvancedExampleViewController.m
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/10/14.
//
//

#import "ScanViewController.h"
#import "MTBBarcodeScanner.h"
#import "GameController.h"
#import "BoardViewController.h"
#import "Game.h"
#import "AnimatedGameView.h"
#import "SideToMoveController.h"
#import "Constants.h"

#include "../../Chess/position.h"

@class GameController;
@interface ScanViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak) GameController *gameController;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIButton *toggleScanningButton;
@property (nonatomic, strong) UIView *viewOfInterest;
@property (nonatomic, strong) UIImageView *aimIv;
@property (nonatomic, strong) UIButton *switchCameraButton;
@property (nonatomic, strong) UIButton *toggleTorchButton;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableDictionary *overlayViews;
@property (nonatomic, assign) BOOL didShowAlert;
@property (nonatomic, assign) BOOL captureIsFrozen;
@property (nonatomic, assign) BOOL didShowCaptureWarning;
@property (nonatomic, strong) AnimatedGameView *animatedGameView;
@property (nonatomic, strong) UILabel *progress;


@end

@implementation ScanViewController {
    GameController *__weak gameController;
    RootView *rootView;
    UIView *contentView;
    UIButton *toggleScanningButton;
    UIButton *switchCameraButton;
    UIButton *toggleTorchButton;
    UIView *previewView;
    UIView *viewOfInterest;
    UIImageView *aimIv;
    BOOL captureIsFrozen;
    BOOL didShowCaptureWarning;
    UIPopoverController *popoverMenu;
    AnimatedGameView *animatedGameView;
    UILabel *progress;
    NSTimer *timer;
    int currSeconds;
    BOOL codeAlreadyRead;
}

@synthesize boardViewController, animatedGameView, viewOfInterest, aimIv, toggleScanningButton, toggleTorchButton, didShowCaptureWarning, gameController, captureIsFrozen, previewView, switchCameraButton, progress;

#pragma mark - Lifecycle

- (id)init {
    if (self = [super init]) {
        [self setTitle:[[NSBundle mainBundle] infoDictionary][@"CFBundleName"]];
    }   return self;
}

- (id)initWithBoardViewController:(BoardViewController *)bvc{
    if (self = [super init]) {
        boardViewController = bvc;
        [self setPreferredContentSize: CGSizeMake(320.0f, 418.0f)];
    }
    return self;
}

- (void)loadView {
    
    // iPhone or iPod touch
    // Content view
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    
    rootView = [[RootView alloc] initWithFrame: appRect];
    //[rootView setBackgroundColor: [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha: 1.0]];
    [rootView setBackgroundColor: [UIColor colorWithRed:0.934 green:0.934 blue:0.953 alpha: 1.0]];
    
    //appRect.origin = CGPointMake(0.0f, 20.0f);
    //appRect.size.height -= 20.0f;
    
    contentView = [[UIView alloc] initWithFrame: appRect];
    [rootView addSubview: contentView];
    [self setView: rootView];
    CGPoint superCenter = CGPointMake(CGRectGetMidX([rootView bounds]), CGRectGetMidY([rootView bounds]));
    
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, appRect.size.width, 460.0f)];
    [self.previewView setHidden:YES];
    [self.previewView setCenter:superCenter];
    
    [self.previewView setBackgroundColor:[UIColor lightGrayColor]];
    [contentView addSubview:self.previewView];
    
    viewOfInterest = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180.0f, 180.0f)];
    [viewOfInterest setCenter:superCenter];
    [viewOfInterest setHidden:YES];
    [viewOfInterest setAlpha:0.3f];
    [viewOfInterest setBackgroundColor:[UIColor clearColor]];
    
    aimIv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"aim"]];
    [aimIv setFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
    [aimIv setCenter:superCenter];
    [aimIv setAlpha:0.3f];
    [contentView addSubview:aimIv];
    [aimIv setHidden:YES];
    [contentView addSubview:viewOfInterest];
    
    switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCameraButton setBackgroundImage:[UIImage imageNamed:@"reverse"] forState:UIControlStateNormal];
    [switchCameraButton addTarget:self action:@selector(switchCameraTapped) forControlEvents:UIControlEventTouchUpInside];
    switchCameraButton.frame = CGRectMake(appRect.size.width-45.0f, 8.0f, 30.0f, 30.0f);
    [self.previewView addSubview:switchCameraButton];
    
    toggleTorchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleTorchButton setBackgroundImage:[UIImage imageNamed:@"flashlight"] forState:UIControlStateNormal];
    [toggleTorchButton addTarget:self action:@selector(toggleTorchTapped) forControlEvents:UIControlEventTouchUpInside];
    toggleTorchButton.frame = CGRectMake(10.0f, 15.0f, 20.0f, 20.0f);
    [self.previewView addSubview:toggleTorchButton];
    
    toggleScanningButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleScanningButton addTarget:self action:@selector(toggleScanningTapped) forControlEvents:UIControlEventTouchUpInside];
    [toggleScanningButton setTitle:@"STOP" forState:UIControlStateNormal];
    [toggleScanningButton setBackgroundColor:[constants colorORANGE]];
    toggleScanningButton.titleLabel.font = [UIFont systemFontOfSize: 20];
    [toggleScanningButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [toggleScanningButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    toggleScanningButton.frame = CGRectMake(0.0f, appRect.size.height-45, appRect.size.width, 45.0f);
    [contentView addSubview:toggleScanningButton];

    
    progress=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [progress setTextAlignment:NSTextAlignmentCenter];
    [progress setCenter:superCenter];
    [progress setFont:[UIFont fontWithName:@"Arial" size:60]];
    progress.textColor=[UIColor blackColor];
    [progress setText:@"3"];
    progress.backgroundColor=[UIColor clearColor];
    [self.view addSubview:progress];
    [progress setHidden:YES];
    currSeconds= 3;
    [contentView addSubview:progress];
}

-(void)startCountDown {
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired {
    if(currSeconds>0){
        [progress setText:[NSString stringWithFormat:@"%d",currSeconds]];
        currSeconds-=1;
    }
    else{
        if (fen) {
            [self editPositionWithFen:fen];
        }else{
            [self loadGameWithPgn:pgn];
        }
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[self navigationItem]setTitle:@"Scan new board"];;
    
    currSeconds = 2;
    [progress setText:@"3"];
    codeAlreadyRead = NO;
    
    //inicializando já com scanner ligado
    [self toggleScanningTapped];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [timer invalidate];
}

#pragma mark - Scanner

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.previewView];
    }
    return _scanner;
}

#pragma mark - Overlay Views

- (NSMutableDictionary *)overlayViews {
    if (!_overlayViews) {
        _overlayViews = [[NSMutableDictionary alloc] init];
    }
    return _overlayViews;
}

#pragma mark - Scanning

- (void)startScanning {
    
    self.scanner.didStartScanningBlock = ^{
        NSLog(@"The scanner started scanning!");
    };
    
    self.scanner.didTapToFocusBlock = ^(CGPoint point){
        NSLog(@"The user tapped the screen to focus. \
              Here we could present a view at %@", NSStringFromCGPoint(point));
    };
    
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        [self drawOverlaysOnCodes:codes];
    }];
}

- (void)drawOverlaysOnCodes:(NSArray *)codes {
    // Get all of the captured code strings
    NSMutableArray *codeStrings = [[NSMutableArray alloc] init];
    for (AVMetadataMachineReadableCodeObject *code in codes) {
        if (code.stringValue) {
            [codeStrings addObject:code.stringValue];
        }
    }
    
    // Remove any code overlays no longer on the screen
    for (NSString *code in self.overlayViews.allKeys) {
        if ([codeStrings indexOfObject:code] == NSNotFound) {
            // A code that was on the screen is no longer
            // in the list of captured codes, remove its overlay
            [self.overlayViews[code] removeFromSuperview];
            [self.overlayViews removeObjectForKey:code];
        }
    }
    
    for (AVMetadataMachineReadableCodeObject *code in codes) {
        UIView *view = nil;
        NSString *codeString = code.stringValue;
        
        if (codeString) {
            if (self.overlayViews[codeString]) {
                // The overlay is already on the screen
                view = self.overlayViews[codeString];
                
                // Move it to the new location
                view.frame = code.bounds;
                
            } else {
                // First time seeing this code
                NSString *kindOfGame = [self whatKindOfGameIs:codeString];
                
                // Create an overlay
                UIView *overlayView = [self overlayForCodeString:codeString
                                                          bounds:code.bounds
                                                            kind:kindOfGame];
                self.overlayViews[codeString] = overlayView;
                
                // Add the overlay to the preview view
                [self.previewView addSubview:overlayView];
                
                if(codeAlreadyRead == NO){
                    
                    if([kindOfGame isEqualToString:@"fen"]){
                        
                        fen = codeString;
                        [progress setHidden:NO];
                        [self startCountDown];
                        codeAlreadyRead = YES;
                        
                    }else if([kindOfGame isEqualToString:@"pgn"]){
                        pgn = codeString;
                        [progress setHidden:NO];
                        [self startCountDown];
                        codeAlreadyRead = YES;
                    }
                }
                
            }
        }
    }
}


- (NSString *)whatKindOfGameIs:(NSString *)codeString {
    //    BOOL stringIsValid = ([codeString rangeOfString:@"/"].location != NSNotFound);
    NSString *kindOfGame;
    if (Position::is_valid_fen([codeString UTF8String])) {
        kindOfGame = @"fen";
    }else if(1 == 1){
        //AQUI IRÁ A LÓGICA PARA VALIDAR SE É UMA STRING PGN VÁLIDA
        kindOfGame = @"pgn";
    }else {
        kindOfGame = @"invalid";
    }
    return kindOfGame;
}

- (UIView *)overlayForCodeString:(NSString *)codeString bounds:(CGRect)bounds kind:(NSString *)aKind {
    
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    
    
    if([aKind isEqualToString:@"invalid"]){
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        
        // Configure the view
        view.layer.borderWidth = 5.0;
        view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.75];
        view.layer.borderColor = [UIColor redColor].CGColor;
        
        // Configure the label
        label.font = [UIFont boldSystemFontOfSize:12];
        label.text = @"INVALID";
        //    label.text = codeString;
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        
        // Add constraints to label to improve text size?
        
        // Add the label to the view
        [view addSubview:label];
        
    }else if([aKind isEqualToString:@"fen"]){
        
        
        Game *g = [[Game alloc] initWithGameController: nil FEN:codeString];
        AnimatedGameView *agv = [[AnimatedGameView alloc]
                                 initWithGame: g
                                 frame: view.bounds];
        
        [view addSubview:agv];
        
    }else{
 
        
        Game *g = [[Game alloc] initWithGameController: nil PGNString:codeString];
        AnimatedGameView *agv = [[AnimatedGameView alloc]
                                 initWithGame: g
                                 frame: view.bounds];
        
        [view addSubview:agv];
        [agv startAnimation];
        
        
    }
    
    return view;
}

- (void)stopScanning {
    [self.scanner stopScanning];
    
    for (NSString *code in self.overlayViews.allKeys) {
        [self.overlayViews[code] removeFromSuperview];
    }
}

#pragma mark - Actions

- (void)toggleScanningTapped {
    if ([self.scanner isScanning]) {
        [self stopScanning];
        [self.previewView setHidden:YES];
        [aimIv setHidden:YES];
        [viewOfInterest setHidden:YES];
        [self cancelPressed];
    } else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self.previewView setHidden:NO];
                [viewOfInterest setHidden:NO];
                [aimIv setHidden:NO];
                [self startScanning];
            } else {
                [self.previewView setHidden:YES];
                [viewOfInterest setHidden:YES];
                [aimIv setHidden:YES];
                [self displayPermissionMissingAlert];
            }
        }];
    }
}

- (void)switchCameraTapped {
    [self.scanner flipCamera];
}

- (void)toggleTorchTapped {
    if (self.scanner.torchMode == MTBTorchModeOff || self.scanner.torchMode == MTBTorchModeAuto) {
        self.scanner.torchMode = MTBTorchModeOn;
    } else {
        self.scanner.torchMode = MTBTorchModeOff;
    }
}

- (void)backTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    self.scanner.scanRect = self.viewOfInterest.frame;
}

#pragma mark - Helper Methods

- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have permission to use the camera.";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

-(void)cancelPressed{
    
    [self.scanner stopScanning];
    
    BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
    [bvc editPositionCancelPressed];
}


- (void)loadGameWithPgn:(NSString *)aPgn{
    
    [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
    BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
    [bvc loadMenuDonePressedWithGame:aPgn];
    
}

- (void)editPositionWithFen:(NSString *)afen {
    
    [self stopScanning];
    [self.previewView setHidden:YES];
    [progress setHidden:YES];
    [viewOfInterest setHidden:YES];
    [aimIv setHidden:YES];
    
    //    SetupViewController *svc = [[SetupViewController alloc]initWithBoardViewController:(BoardViewController *)self fen:fen];
    //    navigationController = [[UINavigationController alloc] initWithRootViewController: svc];
    
    //    SetupViewController *svc = [[SetupViewController alloc]initWithScanViewController:self fen:afen];
    //    [[self navigationController]  pushViewController:svc animated:YES];
    
    SideToMoveController *stmc = [[SideToMoveController alloc]initWithFen: afen];
    [[self navigationController] pushViewController: stmc animated: YES];
    
    [[Options sharedOptions] setGameLevel: LEVEL_2S_PER_MOVE];
    [boardViewController levelWasChanged];
    
//    BoardViewController *bvc = [(ScanViewController *)[[self navigationController] viewControllers][0]boardViewController];
//    [bvc editPositionDonePressed:fen];
    
}


@end