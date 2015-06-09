//
//  SensimityUUIDField.m
//

#import "SensimityUUIDField.h"
#import "AppDelegate.h"

@interface SensimityUUIDField ()

@property (strong, nonatomic) NSMutableArray *autoCompleteArray;

@end

@implementation SensimityUUIDField

// Add a orange border to the textfields
- (void)drawRect:(CGRect)rect {
    _bottomBorder = [CALayer layer];
    _bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 1, self.frame.size.width, 1.0f);
    _bottomBorder.backgroundColor = [UIColor colorWithRed:0.255 green:0.259 blue:0.255 alpha:1].CGColor;
    [self.layer addSublayer:_bottomBorder];
    [self setDelegate:self];
}

// Set regular Sensimity brown color bottom border
- (void) setRegularBorderColor {
    _bottomBorder.backgroundColor = [UIColor colorWithRed:0.255 green:0.259 blue:0.255 alpha:1].CGColor;
}

// Set error red color bottom border
- (void) setErrorBorderColor {
    _bottomBorder.backgroundColor = [UIColor redColor].CGColor;
}

- (void) refreshAutoCompleteArray {
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ConfiguredBeacon" inManagedObjectContext:context];
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setEntity:entity];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"uuid"]]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    NSArray* result = [context executeFetchRequest:fetchRequest error:nil];

    _autoCompleteArray = [[NSMutableArray alloc] init];
    for (NSManagedObject* object in result) {
        NSDictionary *autoCompleteItem = [NSDictionary dictionaryWithObjectsAndKeys:[object valueForKey:@"uuid"], @"DisplayText", nil];
        if (![_autoCompleteArray containsObject:autoCompleteItem]) {
            [_autoCompleteArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[object valueForKey:@"uuid"], @"DisplayText", nil]];
        }
    }
}

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    return _autoCompleteArray;
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
        [self setHidden:NO];
    } else {
        [self setText:[result objectForKey:@"DisplayText"]];
    }
}

@end