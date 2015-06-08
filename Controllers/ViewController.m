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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SensimityView" owner:self.scrollView options:nil];
    SensimityView *sensimityView = [nib objectAtIndex:0];
    [self.scrollView setScrollEnabled:YES];
    [sensimityView construct];
    [self.scrollView addSubview:sensimityView];
    
    // add constraint to fit in the scrollview
    NSDictionary *views = NSDictionaryOfVariableBindings(sensimityView);
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[sensimityView]-0-|" options:0 metrics:nil views:views]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sensimityView]-0-|" options:0 metrics:nil views:views]];
    
    // Handle the scrollview height when the keyboard is shown or gone hiding
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardSize.height);
}

// Set scrollview to original height when hiding the keyboard
- (void)keyboardWillBeHidden:(NSNotification*)notification {
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
