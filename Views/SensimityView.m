//
//  SensimityView.m
//

#import "SensimityView.h"
#import "SensimityTextField.h"
#import "BeaconValidator.h"

@interface SensimityView ()

@property (weak, nonatomic) IBOutlet SensimityTextField *uuid;
@property (weak, nonatomic) IBOutlet SensimityTextField *majorNumber;
@property (weak, nonatomic) IBOutlet SensimityTextField *minorNumber;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelUuid;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMajorNumber;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMinorNumber;
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
        [self setButtonStart];
    } else {
        if ([self validateForm]) {
            [self startScanning];
        } else {
            // Show error message if form not containing valid values
            [self showErrorWithButton:_toggleButton message:@"FORM INVALID"];
        }
    }
}

- (void) startScanning {
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
    [self setButtonStop];
}

/**
 * Set the button with the startvalue and (background)colors
 */
- (void) setButtonStart {
    [_toggleButton setTitle:@"START" forState:UIControlStateNormal];
    [_toggleButton setTitleColor:[UIColor colorWithRed:0.325 green:0.337 blue:0.353 alpha:1] forState:UIControlStateNormal];
    [_toggleButton setBackgroundColor:[UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1]];
    _running = FALSE;
}

/**
 * Set the button with the stopvalue and (background)colors
 */
- (void) setButtonStop {
    [_toggleButton setTitle:@"STOP" forState:UIControlStateNormal];
    [_toggleButton setTitleColor:[UIColor colorWithRed:0.949 green:0.663 blue:0 alpha:1] forState:UIControlStateNormal];
    [_toggleButton setBackgroundColor:[UIColor colorWithRed:0.325 green:0.337 blue:0.353 alpha:1]];
    _running = TRUE;
}

/**
 * Set the button with the errorvalue and (background)colors
 */
- (void) setButtonFormInvalid:(NSString * )text {
    [_toggleButton setBackgroundColor:[UIColor redColor]];
    [_toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_toggleButton setTitle:text forState:UIControlStateNormal];
}

/**
 * Handle start or stop advertising
 */
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
        [self showErrorWithButton:_toggleButton message:@"BLUETOOTH IS NOT ENABLED"];
        // Bluetooth isn't enabled. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        // Unsupported
        [self showErrorWithButton:_toggleButton message:@"IBEACONS NOT SUPPORTED"];
    }
}

/**
 * Show the error and show the startbutton after a timeout
 */
- (void)showErrorWithButton:(UIButton *)button message:(NSString *)text
{
    [self setButtonFormInvalid:text];

    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self setButtonStart];
    });
}

/**
 * Hide keyboard
 */
- (void)dismissKeyboard {
    [_uuid resignFirstResponder];
    [_majorNumber resignFirstResponder];
    [_minorNumber resignFirstResponder];
}

/**
 * Handle the button to hide the keyboard
 */
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return NO;
}

// set textfield
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self validateForm];
    return YES;
}

- (BOOL)validateForm
{
    BeaconValidator* beaconValidator = [[BeaconValidator alloc] init];
    
    BOOL formIsValid = 1;
    if (![beaconValidator isValidUUID:_uuid.text]) {
        formIsValid = 0;
        _errorLabelUuid.text = @"UUID is not valid";
        [_uuid setErrorBorderColor];
    } else {
        _errorLabelUuid.text = @"";
        [_uuid setRegularBorderColor];
    }

    if (![beaconValidator isValidInt:_majorNumber.text]) {
        formIsValid = 0;
        _errorLabelMajorNumber.text = @"Majornumber is not a number";
        [_majorNumber setErrorBorderColor];
    } else {
        _errorLabelMajorNumber.text = @"";
        [_majorNumber setRegularBorderColor];
    }

    if (![beaconValidator isValidInt:_minorNumber.text]) {
        formIsValid = 0;
        _errorLabelMinorNumber.text = @"Minornumber is not a number";
        [_minorNumber setErrorBorderColor];
    } else {
        _errorLabelMinorNumber.text = @"";
        [_minorNumber setRegularBorderColor];
    }

    return formIsValid;
}

@end
