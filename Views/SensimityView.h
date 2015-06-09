//
//  SensimityView.h
//

#import <UIKit/UIKit.h>
#import "SensimityTextField.h"
#import "SensimityUUIDField.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SensimityView : UIView<UITextFieldDelegate, MPGTextFieldDelegate, CBPeripheralManagerDelegate>

@property (strong, nonatomic) NSDictionary *myBeaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

/**
 * Constructor to sets the delegates and tapgestures
 */
- (void) construct;

@end
