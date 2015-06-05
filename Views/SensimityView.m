//
//  SensimityView.m
//

#import "SensimityView.h"


@interface SensimityView ()

@property (weak, nonatomic) IBOutlet UITextField *uuid;
@property (weak, nonatomic) IBOutlet UITextField *majorNumber;
@property (weak, nonatomic) IBOutlet UITextField *minorNumber;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property BOOL running;

@end

@implementation SensimityView

/**
 * Constructor to sets the delegates and tapgestures
 */
- (void) construct {
    // Do any additional setup after loading the view, typically from a nib.
    _running = FALSE;
    
    // Add a listener to hide the keyboard if user clickes outside the keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self addGestureRecognizer:tap];
    
    [_uuid setDelegate:self];
    [_majorNumber setDelegate:self];
    [_minorNumber setDelegate:self];
}

// Start or stop the beaconadvertisement
- (IBAction)buttonClicked:(id)sender {
    if (_running) {
        [self.peripheralManager stopAdvertising];
        [self setToggleButtonStart];
    } else {
        // Create a NSUUID object
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[_uuid text]];
        
        // Initialize the Beacon Region
        CLBeaconRegion *myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                                 major:[[_majorNumber text] intValue]
                                                                                 minor:[[_minorNumber text] intValue]
                                                                            identifier:@"com.enrise.sensimity.chameleon"];
        // Get the beacon data to advertise
        self.myBeaconData = [myBeaconRegion peripheralDataWithMeasuredPower:nil];
        
        // Start the peripheral manager
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
        [self setToggleButtonStop];
    }
}

-(void)setToggleButtonStart{
    [_toggleButton setTitle:@"START" forState:UIControlStateNormal];
    [_toggleButton setTitleColor:[UIColor colorWithRed:0.325 green:0.337 blue:0.353 alpha:1] forState:UIControlStateNormal];
    [_toggleButton setBackgroundColor:[UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1]];
    _running = FALSE;
}

-(void)setToggleButtonStop{
    [_toggleButton setTitle:@"STOP" forState:UIControlStateNormal];
    [_toggleButton setTitleColor:[UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1] forState:UIControlStateNormal];
    [_toggleButton setBackgroundColor:[UIColor colorWithRed:0.325 green:0.337 blue:0.353 alpha:1]];
    _running = TRUE;
}

// Handle start or stop advertising
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        // Bluetooth is on
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.myBeaconData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        [self shakeButton:_toggleButton withErrorMessage:@"BLUETOOTH IS NOT ENABLED"];
        // Bluetooth isn't on. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        [self shakeButton:_toggleButton withErrorMessage:@"IBEACONS NOT SUPPORTED"];
        // Unsupported
    }
}

- (void)shakeButton:(UIButton *)button withErrorMessage:(NSString *)text
{
    [UIView setAnimationsEnabled:NO];
    [_toggleButton setBackgroundColor:[UIColor redColor]];
    [_toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_toggleButton setTitle:text forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];

    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.duration = 0.05;
    animation.byValue = @(5);
    animation.autoreverses = YES;
    animation.repeatCount = 10;
    [CATransaction setCompletionBlock:^{
        [self setToggleButtonStart];
    }];
    [button.layer addAnimation:animation forKey:@"Shake"];
    [CATransaction commit];
}

/**
 * Hide keyboard
 */
-(void)dismissKeyboard {
    [_uuid resignFirstResponder];
    [_majorNumber resignFirstResponder];
    [_minorNumber resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
@end
