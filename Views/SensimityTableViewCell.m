//
//  Sensimity Chameleon
//

#import "SensimityTableViewCell.h"

@interface SensimityTableViewCell()

/**
 *  The outlet of the title
 */
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SensimityTableViewCell

#pragma mark - Custom Accessors

/**
 *  Set the text of this cell
 *
 *  @param text The text which should be shown
 */
- (void)setTitleLabelText:(NSString *)text {
    self.titleLabel.text = text;
}

@end