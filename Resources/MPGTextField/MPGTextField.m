//
//  MPGTextField.m
//
//  Created by Gaurav Wadhwani on 05/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

#import "MPGTextField.h"
#import "SensimityTableViewCell.h"
#import "QuartzCore/QuartzCore.h"
#import "UIColor+ColorExtensions.h"

@implementation MPGTextField

@synthesize delegate;

//Private declaration of UITableViewController that will present the results in a popover depending on the search query typed by the user.
UITableViewController *results;
UITableViewController *tableViewController;

/**
 *  Private declaration of NSArray that will hold the data supplied by the user for showing results in search popover.
 */
NSArray *data;

/**
 *  Layout subviews to provide suggestions
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.text.length > 0) {
        //User entered some text in the textfield. Check if the delegate has implemented the required method of the protocol. Create a popover and show it around the MPGTextField.
        if ([self.delegate respondsToSelector:@selector(dataForPopoverInTextField:)]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                data = [[self delegate] dataForPopoverInTextField:self];
                [self provideSuggestions];
            });
        } else {
            NSLog(@"<MPGTextField> WARNING: You have not implemented the requred methods of the MPGTextField protocol.");
        }
    } else {
        //No text entered in the textfield. If -textFieldShouldSelect is YES, select the first row from results using -handleExit method.tableView and set the displayText on the text field. Check if suggestions view is visible and dismiss it.
        if ([tableViewController.tableView superview] != nil) {
            [tableViewController.tableView removeFromSuperview];
        }
    }
}

/**
 *  Override UITextField -resignFirstResponder method to ensure the 'exit' is handled properly.
 *
 *  @return super resignFirstResponder
 */
- (BOOL)resignFirstResponder {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handleExit];
    });
    return [super resignFirstResponder];
}

/**
 *  This method checks if a selection needs to be made from the suggestions box using the delegate method -textFieldShouldSelect. If a user doesn't tap any search suggestion, the textfield automatically selects the top result. If there is no result available and the delegate method is set to return YES, the textfield will wrap the entered the text in a NSDictionary and send it back to the delegate with 'CustomObject' key set to 'NEW'
 */
- (void)handleExit {
    if (tableViewController) {
        [UIView animateWithDuration:0.3 animations:^{
            [tableViewController.tableView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [tableViewController.tableView removeFromSuperview];
        }];
        [tableViewController.tableView removeFromSuperview];
        tableViewController = nil;
    }
    if ([[self delegate] respondsToSelector:@selector(textFieldShouldSelect:)]) {
        if ([[self delegate] textFieldShouldSelect:self]) {
            if ([self applyFilterWithSearchQuery:self.text].count > 0) {
                self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0] objectForKey:@"DisplayText"];
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[[self applyFilterWithSearchQuery:self.text] objectAtIndex:0]];
                } else {
                    NSLog(@"<MPGTextField> WARNING: You have not implemented a method from MPGTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            } else if (self.text.length > 0) {
                //Make sure that delegate method is not called if no text is present in the text field.
                if ([[self delegate] respondsToSelector:@selector(textField:didEndEditingWithSelection:)]) {
                    [[self delegate] textField:self didEndEditingWithSelection:[NSDictionary dictionaryWithObjectsAndKeys:self.text,@"DisplayText",@"NEW",@"CustomObject", nil]];
                } else {
                    NSLog(@"<MPGTextField> WARNING: You have not implemented a method from MPGTextFieldDelegate that is called back when the user selects a search suggestion.");
                }
            }
        }
    }
}


#pragma mark UITableView DataSource & Delegate Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[self applyFilterWithSearchQuery:self.text] count];
    if (count == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            [tableViewController.tableView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [tableViewController.tableView removeFromSuperview];
            tableViewController = nil;
        }];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SensimityTableViewCell" owner:self options:nil];
    SensimityTableViewCell *cell = [nib objectAtIndex:0];
    
    NSDictionary *dataForRowAtIndexPath = [[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row];
    [cell setTitleLabelText:[dataForRowAtIndexPath objectForKey:@"DisplayText"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.text = [[[self applyFilterWithSearchQuery:self.text] objectAtIndex:indexPath.row] objectForKey:@"DisplayText"];
    [self resignFirstResponder];
}

#pragma mark Filter Method

/**
 *  Check a value inside the data-array starts with the filter
 *
 *  @param filter the filterstring
 *
 *  @return The filtered values
 */
- (NSArray *)applyFilterWithSearchQuery:(NSString *)filter {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"DisplayText BEGINSWITH[cd] %@", filter];
    NSArray *filteredGoods = [NSArray arrayWithArray:[data filteredArrayUsingPredicate:predicate]];
    return filteredGoods;
}

#pragma mark Popover Method(s)

/**
 *  Providing suggestions
 */
- (void)provideSuggestions {
    if (tableViewController.tableView.superview == nil && [[self applyFilterWithSearchQuery:self.text] count] > 0) {
        [self setupTappingGestureRecognizer];
        
        tableViewController = [[UITableViewController alloc] init];
        [tableViewController.tableView setBounces:NO];
        [tableViewController.tableView setAlwaysBounceVertical:NO];
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        [tableViewController.tableView setBackgroundColor:[UIColor sensimityBackgroundColor]];
        [tableViewController.tableView setSeparatorColor:[UIColor sensimityBackgroundColor]];
        [self setHeightOfFrame];

        [[self superview] addSubview:tableViewController.tableView];
        [tableViewController.tableView setAlpha:0.9];
    } else {
        [tableViewController.tableView reloadData];
    }
}

- (void)setHeightOfFrame {
    //PopoverSize frame has not been set. Use default parameters instead.
    CGRect frameForPresentation = [self frame];
    frameForPresentation.origin.y += self.frame.size.height;
    frameForPresentation.size.height = 200;
    [tableViewController.tableView setFrame:frameForPresentation];
}

- (void)setupTappingGestureRecognizer {
    //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setCancelsTouchesInView:NO];
    [tapRecognizer setDelegate:self];
    [self.superview addGestureRecognizer:tapRecognizer];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
}

@end
