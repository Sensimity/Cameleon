//
//  ViewController.m
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SensimityView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

/**
 *  View did load, add sensimityview to a scrollview
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.scrollEnabled = YES;
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SensimityView" owner:self.scrollView options:nil];
    SensimityView *sensimityView = [nib objectAtIndex:0];
    [sensimityView construct];
    [self.scrollView addSubview:sensimityView];
    
    // add constraint to fit in the scrollview
    NSDictionary *views = NSDictionaryOfVariableBindings(sensimityView);
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sensimityView]-0-|" options:0 metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sensimityView]-0-|" options:0 metrics:nil views:views]];
}

@end
