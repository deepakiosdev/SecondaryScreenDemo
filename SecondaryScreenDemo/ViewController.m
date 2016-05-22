//
//  ViewController.m
//  SecondaryScreenDemo
//
//  Created by Deepak on 22/05/16.
//  Copyright © 2016 Deepak. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIScreen *mirroredScreen;
@property (nonatomic, strong) UIWindow *mirroredWindow;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *greenView;


@end

@implementation ViewController
- (IBAction)airPlayAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self setupOutputScreen];
    } else {
        [self disableMirroringOnCurrentScreen];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
    [center addObserver:self selector:@selector(screenModeDidChange:) name:UIScreenModeDidChangeNotification object:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
    [center removeObserver:self name:UIScreenModeDidChangeNotification object:nil];
    [super viewWillDisappear:animated];
}


#pragma mark - airplay methods
- (void)setupOutputScreen
{

    // Setup screen mirroring for an existing screen
    NSArray *connectedScreens = [UIScreen screens];
    NSLog(@"connectedScreens count:%lu: ",(unsigned long)connectedScreens.count);
    if ([connectedScreens count] > 1)
    {
        UIScreen *mainScreen = [UIScreen mainScreen];
        for (UIScreen *aScreen in connectedScreens)
        {
            if (aScreen != mainScreen)
            {
                [self setupMirroringForScreen:aScreen];
                break;
            }
        }
    } else {
        //Show Alert
    }
}

- (void)screenDidConnect:(NSNotification *)aNotification
{
    NSLog(@"A new screen got connected: %@", [aNotification object]);
    [self setupMirroringForScreen:[aNotification object]];
}

- (void)screenDidDisconnect:(NSNotification *)aNotification
{
    NSLog(@"A screen got disconnected: %@", [aNotification object]);
    [self disableMirroringOnCurrentScreen];
}

- (void)screenModeDidChange:(NSNotification *)aNotification
{
    NSLog(@"A screen mode changed: %@", [aNotification object]);
    [self disableMirroringOnCurrentScreen];
    [self setupMirroringForScreen:[aNotification object]];
}

- (void)disableMirroringOnCurrentScreen
{
    NSLog(@"disableMirroringOnCurrentScreen");

     for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    self.mirroredWindow.hidden = YES;
    self.mirroredWindow = nil;
    self.mirroredScreen = nil;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.view addSubview:self.greenView];

    });
    
}

- (void)setupMirroringForScreen:(UIScreen *)anExternalScreen
{
    NSLog(@"");
    self.mirroredScreen = anExternalScreen;
    // Find max resolution
    CGSize max = {0, 0};
    UIScreenMode *maxScreenMode = nil;
    
    for (UIScreenMode *current in self.mirroredScreen.availableModes) {
        if (maxScreenMode == nil || current.size.height > max.height || current.size.width > max.width) {
            max = current.size;
            maxScreenMode = current;
        }
    }
    self.mirroredScreen.currentMode = maxScreenMode;
    
    // Set a proper overscanCompensation mode
    self.mirroredScreen.overscanCompensation = UIScreenOverscanCompensationNone;
    
    // Setup window in external screen
    self.mirroredWindow = [[UIWindow alloc] initWithFrame:self.mirroredScreen.bounds];

    self.mirroredWindow.hidden  = NO;
    self.mirroredWindow.layer.contentsGravity = kCAGravityResizeAspect;
    self.mirroredWindow.screen  = self.mirroredScreen;
    
    self.containerView   = [[UIView alloc] initWithFrame: self.mirroredScreen.bounds];
    self.containerView.backgroundColor = [UIColor redColor];
    [self.containerView.layer addSublayer:self.greenView.layer];
    self.containerView.layer.frame = self.mirroredScreen.bounds;
    [self.mirroredWindow addSubview:self.containerView];
}

@end
