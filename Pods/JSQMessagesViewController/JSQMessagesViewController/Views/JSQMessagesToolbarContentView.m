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



- (IBAction)customKeyboardShow:(UIButton *)sender;
- (IBAction)normalKeyboardShow:(UIButton *)sender;

@end

CGRect keyboardFrameBeginRect;


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
    
    UIImage *finance_before = [UIImage imageNamed:@"finance_before.png"];
    UIImage *booking_before = [UIImage imageNamed:@"booking_before.png"];
    UIImage *health_before = [UIImage imageNamed:@"health_before.png"];
    UIImage *home_before = [UIImage imageNamed:@"home_before.png"];
    UIImage *shopping_before = [UIImage imageNamed:@"shopping_before.png"];
    UIImage *food_before = [UIImage imageNamed:@"food_before.png"];
    UIImage *keyboard_before = [UIImage imageNamed:@"keyboard_before.png"];
    
    UIImage *finance_after = [UIImage imageNamed:@"finance_after.png"];
    UIImage *booking_after = [UIImage imageNamed:@"booking_after.png"];
    UIImage *health_after = [UIImage imageNamed:@"health_after.png"];
    UIImage *home_after = [UIImage imageNamed:@"home_after.png"];
    UIImage *shopping_after = [UIImage imageNamed:@"shopping_after.png"];
    UIImage *food_after = [UIImage imageNamed:@"food_after.png"];
    UIImage *keyboard_after = [UIImage imageNamed:@"keyboard_after.png"];

    [self.financeButton setImage:finance_before forState:UIControlStateNormal];
    [self.bookingButton setImage:booking_before forState:UIControlStateNormal];
    [self.healthButton setImage:health_before forState:UIControlStateNormal];
    [self.homeButton setImage:home_before forState:UIControlStateNormal];
    [self.shoppingButton setImage:shopping_before forState:UIControlStateNormal];
    [self.foodButton setImage:food_before forState:UIControlStateNormal];
    [self.keyboardButton setImage:keyboard_before forState:UIControlStateNormal];
    
    
    [self.financeButton setImage:finance_after forState:(UIControlStateSelected)];
    [self.bookingButton setImage:booking_after forState:(UIControlStateSelected)];
    [self.healthButton setImage:health_after forState:(UIControlStateSelected)];
    [self.homeButton setImage:home_after forState:(UIControlStateSelected)];
    [self.shoppingButton setImage:shopping_after forState:(UIControlStateSelected)];
    [self.foodButton setImage:food_after forState:(UIControlStateSelected)];
    [self.keyboardButton setImage:keyboard_after forState:(UIControlStateSelected)];
    
    self.keyboardButton.selected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    
    self.backgroundColor = [UIColor clearColor];
}


- (void)keyboardShown:(NSNotification*)notification
{
    keyboardFrameBeginRect = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
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
    static NSDictionary *keyboardHeights = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardHeights = @{
                   @"667": [NSNumber numberWithInt:258], //iPhone 6
                   @"736": [NSNumber numberWithInt:271], //iPhone 6 Plus
                   @"568": [NSNumber numberWithInt:253], //iPhone 5s & 5
                   @"480": [NSNumber numberWithInt:253] //iPhone 4s
                   };
    });
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    int keyboardHeight = 253;
    keyboardHeight = [[keyboardHeights objectForKey: [NSNumber numberWithFloat:screenHeight].stringValue] intValue];
    UIView *view = [[UIView alloc]initWithFrame: CGRectMake(0, 0, screenWidth, keyboardHeight)];
    view.backgroundColor = [UIColor grayColor];
    
//    [self.textView resignFirstResponder];
    self.textView.inputView = view;
    [self.textView becomeFirstResponder];
    [self.textView reloadInputViews];
    NSArray* buttons = [NSArray arrayWithObjects:self.financeButton, self.bookingButton, self.healthButton, self.homeButton, self.foodButton, self.shoppingButton, self.keyboardButton, nil];
    for (UIButton* button in buttons) {
        if (button == sender) {
            button.selected = YES;
        }
        else {
            button.selected = NO;
        }
    }
}

- (IBAction)normalKeyboardShow:(UIButton *)sender {
//    [self.textView resignFirstResponder];
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];
    [self.textView reloadInputViews];
    self.keyboardButton.selected = YES;
    NSArray* buttons = [NSArray arrayWithObjects:self.financeButton, self.bookingButton, self.healthButton, self.homeButton, self.foodButton, self.shoppingButton, nil];
    for (UIButton* button in buttons) {
        button.selected = NO;
    }
}



@end
