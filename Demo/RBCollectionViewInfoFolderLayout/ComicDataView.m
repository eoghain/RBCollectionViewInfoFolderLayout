//
//  ComicDataView.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/4/14.
//
//

#import "ComicDataView.h"

@implementation ComicDataView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.clipsToBounds = YES;

		self.title = [[UILabel alloc] init];
		self.title.translatesAutoresizingMaskIntoConstraints = NO;
//		self.title.textAlignment = NSTextAlignmentCenter;
		self.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		self.title.textColor = [UIColor colorWithRed:0x33/250.0 green:0x33/250.0 blue:0x33/250.0 alpha:1.0];
		
		self.desc = [[UILabel alloc] init];
		self.desc.numberOfLines = 0;
		self.desc.translatesAutoresizingMaskIntoConstraints = NO;
		self.desc.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
		self.desc.textColor = [UIColor colorWithRed:0x33/250.0 green:0x33/250.0 blue:0x33/250.0 alpha:1.0];

		self.upc = [[UILabel alloc] init];
		self.upc.translatesAutoresizingMaskIntoConstraints = NO;
		self.upc.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		self.upc.textColor = [UIColor colorWithRed:0x33/250.0 green:0x33/250.0 blue:0x33/250.0 alpha:1.0];

		[self addSubview:self.title];
		[self addSubview:self.desc];
		[self addSubview:self.upc];

		NSMutableArray * constraintsArray = [NSMutableArray array];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.title attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.desc attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.title attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.desc attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.title attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.desc attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.title attribute:NSLayoutAttributeBottom	multiplier:1.0 constant:5.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.upc attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.desc attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.upc attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.desc attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f]];

		[constraintsArray addObject: [NSLayoutConstraint constraintWithItem:self.upc attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.desc attribute:NSLayoutAttributeBottom	multiplier:1.0 constant:5.0f]];


		[self addConstraints:constraintsArray];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
