//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarContentView.h"

#import "UIView+JSQMessages.h"

const CGFloat kJSQMessagesToolbarContentViewHorizontalSpacingDefault = 8.0f;


@interface JSQMessagesToolbarContentView ()

@property (weak, nonatomic) IBOutlet JSQMessagesComposerTextView *textView;

@property (weak, nonatomic) IBOutlet UIView *leftBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBarButtonContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *rightBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBarButtonContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHorizontalSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHorizontalSpacingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *financeButton;
@property (weak, nonatomic) IBOutlet UIButton *bookingButton;
@property (weak, nonatomic) IBOutlet UIButton *healthButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *foodButton;
@property (weak, nonatomic) IBOutlet UIButton *shoppingButton;
@property (weak, nonatomic) IBOutlet UIButton *normalKeyboardButton;
- (IBAction)customKeyboardShow:(UIButton *)sender;


@end



@implementation JSQMessagesToolbarContentView

#pragma mark - Class methods


+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesToolbarContentView class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesToolbarContentView class]]];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.leftHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    
    UIImage *finance = [UIImage imageNamed:@"finance.png"];
    UIImage *booking = [UIImage imageNamed:@"booking.png"];
    UIImage *health = [UIImage imageNamed:@"health.png"];
    UIImage *home = [UIImage imageNamed:@"home.png"];
    UIImage *shopping = [UIImage imageNamed:@"shopping.png"];
    UIImage *food = [UIImage imageNamed:@"food.png"];

    [self.financeButton setImage:finance forState:UIControlStateNormal];
    [self.bookingButton setImage:booking forState:UIControlStateNormal];
    [self.healthButton setImage:health forState:UIControlStateNormal];
    [self.homeButton setImage:home forState:UIControlStateNormal];
    [self.shoppingButton setImage:shopping forState:UIControlStateNormal];
    [self.foodButton setImage:food forState:UIControlStateNormal];
    
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc
{
    _textView = nil;
    _leftBarButtonItem = nil;
    _rightBarButtonItem = nil;
    _leftBarButtonContainerView = nil;
    _rightBarButtonContainerView = nil;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.leftBarButtonContainerView.backgroundColor = backgroundColor;
    self.rightBarButtonContainerView.backgroundColor = backgroundColor;
}

- (void)setLeftBarButtonItem:(UIButton *)leftBarButtonItem
{
    if (_leftBarButtonItem) {
        [_leftBarButtonItem removeFromSuperview];
    }

    if (!leftBarButtonItem) {
        _leftBarButtonItem = nil;
        self.leftHorizontalSpacingConstraint.constant = 0.0f;
        self.leftBarButtonItemWidth = 0.0f;
        self.leftBarButtonContainerView.hidden = YES;
        return;
    }

    if (CGRectEqualToRect(leftBarButtonItem.frame, CGRectZero)) {
        leftBarButtonItem.frame = self.leftBarButtonContainerView.bounds;
    }

    self.leftBarButtonContainerView.hidden = NO;
    self.leftHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.leftBarButtonItemWidth = CGRectGetWidth(leftBarButtonItem.frame);

    [leftBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.leftBarButtonContainerView addSubview:leftBarButtonItem];
    [self.leftBarButtonContainerView jsq_pinAllEdgesOfSubview:leftBarButtonItem];
    [self setNeedsUpdateConstraints];

    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setLeftBarButtonItemWidth:(CGFloat)leftBarButtonItemWidth
{
    self.leftBarButtonContainerViewWidthConstraint.constant = leftBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setRightBarButtonItem:(UIButton *)rightBarButtonItem
{
    if (_rightBarButtonItem) {
        [_rightBarButtonItem removeFromSuperview];
    }

    if (!rightBarButtonItem) {
        _rightBarButtonItem = nil;
        self.rightHorizontalSpacingConstraint.constant = 0.0f;
        self.rightBarButtonItemWidth = 0.0f;
        self.rightBarButtonContainerView.hidden = YES;
        return;
    }

    if (CGRectEqualToRect(rightBarButtonItem.frame, CGRectZero)) {
        rightBarButtonItem.frame = self.rightBarButtonContainerView.bounds;
    }

    self.rightBarButtonContainerView.hidden = NO;
    self.rightHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.rightBarButtonItemWidth = CGRectGetWidth(rightBarButtonItem.frame);

    [rightBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.rightBarButtonContainerView addSubview:rightBarButtonItem];
    [self.rightBarButtonContainerView jsq_pinAllEdgesOfSubview:rightBarButtonItem];
    [self setNeedsUpdateConstraints];

    _rightBarButtonItem = rightBarButtonItem;
}

- (void)setRightBarButtonItemWidth:(CGFloat)rightBarButtonItemWidth
{
    self.rightBarButtonContainerViewWidthConstraint.constant = rightBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Getters

- (CGFloat)leftBarButtonItemWidth
{
    return self.leftBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)rightBarButtonItemWidth
{
    return self.rightBarButtonContainerViewWidthConstraint.constant;
}

#pragma mark - UIView overrides

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.textView setNeedsDisplay];
}

- (IBAction)customKeyboardShow:(UIButton *)sender {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
    view.backgroundColor = [UIColor grayColor];
    
    self.textView.inputAccessoryView = view;
    [self.textView becomeFirstResponder];
}
@end
