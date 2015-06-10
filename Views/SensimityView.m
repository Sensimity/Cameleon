//
//  SensimityView.m
//

#import "SensimityView.h"
#import "AppDelegate.h"
#import "ConfiguredBeaconService.h"
#import "BeaconValidator.h"
#import "UIColor+ColorExtensions.h"

@interface SensimityView ()

@property (weak, nonatomic) IBOutlet SensimityUUIDField *uuid;
@property (weak, nonatomic) IBOutlet SensimityTextField *majorNumber;
@property (weak, nonatomic) IBOutlet SensimityTextField *minorNumber;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelUuid;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMajorNumber;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMinorNumber;

@end

@implementation SensimityView

static NSString * const SensimityFormInvalid = @"FORM INVALID";
static NSString * const SensimityFormStart = @"START";
static NSString * const SensimityFormStop = @"STOP";
static NSString * const SensimityUUIDInvalid = @"UUID is not valid";
static NSString * const SensimityMajorInvalid = @"Majornumber is not a number";
static NSString * const SensimityMinorInvalid = @"Minornumber is not a number";
static NSString * const SensimityBluetoothDisabled = @"BLUETOOTH NOT ENABLED";
static NSString * const SensimityIBeaconsNotSupported = @"IBEACONS NOT SUPPORTED";
static NSString * const SensimityEmpty = @"";

#pragma mark - Lifecycle

/**
 *  Constructor to sets the delegates and tapgestures
 */
- (void) construct {
    [self addDelegatesToTextFields];
}

#pragma mark - IBActions

/**
 * Start or stop the beaconadvertisement
 */
- (IBAction)buttonClicked:(id)sender {
    if (self.peripheralManager.isAdvertising) {
        [self.peripheralManager stopAdvertising];
        [self setButtonStart];
    } else {
        if ([self validateForm]) {
            [self saveBeaconConfig];
            [self startScanning];
        } else {
            // Show error message if form not containing valid values
            [self showErrorWithButton:self.toggleButton
                              message:SensimityFormInvalid];
        }
    }
}

#pragma mark - Private

/**
 * Add delegates to uuid-, major- and minortextfields
 */
- (void)addDelegatesToTextFields {
    self.uuid.delegate = self;
}

/**
 * Save the configuration of the filled-in iBeacon
 */
- (void)saveBeaconConfig {
    ConfiguredBeaconService *configuredBeaconService = [[ConfiguredBeaconService alloc] init];
    NSInteger majorNumber = [[self.majorNumber text] intValue];
    NSInteger minorNumber = [[self.minorNumber text] intValue];
    [configuredBeaconService save:[self.uuid text]
                            major:majorNumber
                            minor:minorNumber];
    [self.uuid refreshAutoCompleteArray];
}

/**
 * Start the scanning of the filled-in uuid, major and minor-values are filled in
 */
- (void)startScanning {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:[self.uuid text]];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:uuid
                                    major:[[self.majorNumber text] intValue]
                                    minor:[[self.minorNumber text] intValue]
                                    identifier:@"com.enrise.sensimity.chameleon"];
    self.beaconData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc]
                              initWithDelegate:self
                              queue:nil
                              options:nil];
    [self setButtonStop];
}

/**
 * Set the button with the startvalue and (background)colors
 */
- (void)setButtonStart {
    [self.toggleButton setTitle:SensimityFormStart
                       forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor sensimityBrownColor]
                            forState:UIControlStateNormal];
    self.toggleButton.backgroundColor = [UIColor sensimityYellowColor];
}

/**
 * Set the button with the stopvalue and (background)colors
 */
- (void)setButtonStop {
    [self.toggleButton setTitle:SensimityFormStop
                       forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor sensimityYellowColor]
                            forState:UIControlStateNormal];
    self.toggleButton.backgroundColor = [UIColor sensimityBrownColor];
}

/**
 * Set the button with the errorvalue and (background)colors
 */
- (void)setButtonFormInvalid:(NSString * )text {
    [self.toggleButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
    [self.toggleButton setTitle:text
                       forState:UIControlStateNormal];
    self.toggleButton.backgroundColor = [UIColor sensimityErrorRedColor];
}

/**
 * Show the error and show the startbutton after a timeout
 */
- (void)showErrorWithButton:(UIButton *)button message:(NSString *)text {
    [self setButtonFormInvalid:text];
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self setButtonStart];
    });
}

/**
 *  Validate the form to validate the uuid, major and minor values. If not correct show the errormessages
 *
 *  @return YES if form if valid, otherwise it returns NO
 */
- (BOOL)validateForm
{
    BeaconValidator* beaconValidator = [[BeaconValidator alloc] init];
    
    BOOL formIsValid = YES;
    if (![beaconValidator isValidUUID:self.uuid.text]) {
        formIsValid = NO;
        self.errorLabelUuid.text = SensimityUUIDInvalid;
        [self.uuid setErrorBorderColor];
    } else {
        self.errorLabelUuid.text = SensimityEmpty;
        [self.uuid setRegularBorderColor];
    }
    
    if (![beaconValidator isValidInt:self.majorNumber.text]) {
        formIsValid = NO;
        self.errorLabelMajorNumber.text = SensimityMajorInvalid;
        [self.majorNumber setErrorBorderColor];
    } else {
        self.errorLabelMajorNumber.text = SensimityEmpty;
        [self.majorNumber setRegularBorderColor];
    }
    
    if (![beaconValidator isValidInt:self.minorNumber.text]) {
        formIsValid = NO;
        self.errorLabelMinorNumber.text = SensimityMinorInvalid;
        [self.minorNumber setErrorBorderColor];
    } else {
        self.errorLabelMinorNumber.text = SensimityEmpty;
        [self.minorNumber setRegularBorderColor];
    }
    
    return formIsValid;
}

#pragma mark - CBPeripheralManagerDelegate

/**
 *  Handle start or stop advertising
 *
 *  @param peripheral The peripheralManager which contains the current state
 */
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // Bluetooth is on
        // Start broadcasting
        [self.peripheralManager startAdvertising:self.beaconData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        [self showErrorWithButton:self.toggleButton
                          message:SensimityBluetoothDisabled];
        // Bluetooth isn't enabled. Stop broadcasting
        [self.peripheralManager stopAdvertising];
    } else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        // Unsupported
        [self showErrorWithButton:self.toggleButton
                          message:SensimityIBeaconsNotSupported];
    }
}

#pragma mark - MPGTextFieldDelegate

/**
 *  This function is called when the
 *
 *  @param textField The textfield which contains a popover, in this case the uuid-textfield
 *
 *  @return The values of the autocompletearray
 */
- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    return [self.uuid getAutoCompleteArray];
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return NO;
}

/**
 *  Check which result is selected and sets that selected uuid in the uuid-textfield
 *
 *  @param textField The textfield which must be changed
 *  @param result    The result which is selected
 */
- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"]) {
        //New Entry
        [self.uuid setHidden:NO];
    } else {
        self.uuid.text = [result objectForKey:@"DisplayText"];
    }
    [self validateForm];
}

@end
