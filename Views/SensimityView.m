//
//  SensimityView.m
//

#import "SensimityView.h"
#import "BeaconValidator.h"
#import "AppDelegate.h"

@interface SensimityView ()

@property (weak, nonatomic) IBOutlet SensimityUUIDField *uuid;
@property (weak, nonatomic) IBOutlet SensimityTextField *majorNumber;
@property (weak, nonatomic) IBOutlet SensimityTextField *minorNumber;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelUuid;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMajorNumber;
@property (weak, nonatomic) IBOutlet UILabel *errorLabelMinorNumber;
@property BOOL running;
@property (strong, nonatomic) NSMutableArray *autoCompleteArray;

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
    
    [self setAutoCompleteArray];
    [_uuid setDelegate:self];
    [_majorNumber setDelegate:self];
    [_minorNumber setDelegate:self];
}

- (void) setAutoCompleteArray {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConfiguredBeacon" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"uuid"]];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        _autoCompleteArray = [[NSMutableArray alloc] init];
        for (NSManagedObject* object in result) {
            [_autoCompleteArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[object valueForKey:@"uuid"], @"DisplayText", nil]];
        }
    }
}
- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.uuid]) {
        return _autoCompleteArray;
    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"]) {
        //New Entry
        [self.uuid setHidden:NO];
    }
    else{
        //Selection from provided data
        if ([textField isEqual:self.uuid]) {
            [self.uuid setText:[result objectForKey:@"DisplayText"]];
        }
    }
}

// Start or stop the beaconadvertisement
- (IBAction)buttonClicked:(id)sender {
    if (_running) {
        [self.peripheralManager stopAdvertising];
        [self setButtonStart];
    } else {
        if ([self validateForm]) {
            [self saveBeaconConfig];
            [self startScanning];
        } else {
            // Show error message if form not containing valid values
            [self showErrorWithButton:_toggleButton message:@"FORM INVALID"];
        }
    }
}

- (void) saveBeaconConfig {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"ConfiguredBeacon" inManagedObjectContext:context];
    
    [entity setValue:[_uuid text] forKey:@"uuid"];
    [entity setValue:[NSNumber numberWithInteger:[[_majorNumber text] intValue]] forKey:@"major"];
    [entity setValue:[NSNumber numberWithInteger:[[_minorNumber text] intValue]] forKey:@"minor"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [self setAutoCompleteArray];
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
