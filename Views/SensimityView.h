//
//  SensimityView.h
//

#import <UIKit/UIKit.h>
#import "SensimityTextField.h"
#import "SensimityUUIDField.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SensimityView : UIView<UITextFieldDelegate, MPGTextFieldDelegate, CBPeripheralManagerDelegate>

/**
 *  The beaconInformation which should be broadcasted
 */
@property (strong, nonatomic) NSDictionary *beaconData;

/**
 *  Ths manager which managed the beacon-broadcasting
 */
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

/**
 *  Constructor to sets the delegates and tapgestures
 */
- (void) construct;

@end
