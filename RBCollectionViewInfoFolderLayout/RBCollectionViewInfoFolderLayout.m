//
//  RBCollectionViewInfoFolderLayout.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import "RBCollectionViewInfoFolderLayout.h"

static NSString *const RBCollectionViewInfoFolderCellKind = @"RBCollectionViewInfoFolderCellKind";
static NSString *const RBCollectionViewInfoFolderDecorationKind = @"RBCollectionViewInfoFolderDecorationKind";
NSString *const RBCollectionViewInfoFolderHeaderKind = @"RBCollectionViewInfoFolderHeaderKind";
NSString *const RBCollectionViewInfoFolderFooterKind = @"RBCollectionViewInfoFolderFooterKind";
NSString *const RBCollectionViewInfoFolderFolderKind = @"RBCollectionViewInfoFolderFolderKind";

// TODO: figure out decorations
//@interface RBCollectionViewInfoFolderDecoration : UICollectionReusableView
//
//@end
//
//@implementation RBCollectionViewInfoFolderDecoration
//
//+ (NSString *)kind
//{
//    return RBCollectionViewInfoFolderDecorationKind;
//}
//// TODO: Create a nice view with a caret that will go over the cell and connect to the folder
//- (void)drawRect:(CGRect)rect
//{
//	UIBezierPath* polygonPath = [UIBezierPath bezierPath];
//	[polygonPath moveToPoint: CGPointMake(22, -0.5)];
//	[polygonPath addLineToPoint: CGPointMake(43.22, 26.5)];
//	[polygonPath addLineToPoint: CGPointMake(0.78, 26.5)];
//	[polygonPath closePath];
//	[[UIColor blueColor] setFill];
//	[polygonPath fill];
//	[[UIColor blackColor] setStroke];
//	polygonPath.lineWidth = 1;
//	[polygonPath stroke];
//}
//
//@end

@interface RBCollectionViewInfoFolderLayout ()

@property (strong, nonatomic) NSMutableDictionary * layoutInformation;
@property (strong, nonatomic) NSMutableDictionary * cellsPerRowInSection;
@property (strong, nonatomic) NSMutableDictionary * visibleFolderInSection;

@end

@implementation RBCollectionViewInfoFolderLayout

- (id)init
{
	self = [super init];
	if (self) {
		[self setup];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		[self setup];
	}

	return self;
}

- (void)setup
{
	self.cellSize = CGSizeMake(200, 200);
	self.headerSize = CGSizeZero;
	self.footerSize = CGSizeZero;
	self.folderHeight = 100.0;
	self.interItemSpacingY = 5.0;
	self.interItemSpacingX = 25.0;

	self.visibleFolderInSection = [NSMutableDictionary dictionary];

	// TODO: figure out decorations
//	self.decorations = [NSMutableDictionary dictionary];
//	[self registerClass:[RBCollectionViewInfoFolderDecoration class] forDecorationViewOfKind:RBCollectionViewInfoFolderDecorationKind];
}


#pragma mark - Properties (Getters & Setters)

- (void)setCellSize:(CGSize)cellSize
{
	if (CGSizeEqualToSize(_cellSize, cellSize))
		return;

	_cellSize = cellSize;
	[self invalidateLayout];
}

- (void)setHeaderSize:(CGSize)headerSize
{
	if (CGSizeEqualToSize(_headerSize, headerSize))
		return;

	_headerSize = headerSize;
	[self invalidateLayout];
}

- (void)setFooterSize:(CGSize)footerSize
{
	if (CGSizeEqualToSize(_footerSize, footerSize))
		return;

	_footerSize = footerSize;
	[self invalidateLayout];
}

- (void)setFolderHeight:(CGFloat)folderHeight
{
	if (_folderHeight == folderHeight)
		return;

	_folderHeight = folderHeight;
	[self invalidateLayout];
}

#pragma mark - Interface

- (void)toggleFolderViewForIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];
	NSArray * reloadPaths = @[ indexPath ];

	if ([visibleFolder isEqual:indexPath])
	{
		[self.visibleFolderInSection removeObjectForKey:@( indexPath.section )];
	}
	else
	{
		if (visibleFolder)
			reloadPaths = [reloadPaths arrayByAddingObject:visibleFolder];
		
		self.visibleFolderInSection[@( indexPath.section )] = indexPath;
	}
	
	[self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]]; // makes animation happen
	[self invalidateLayout]; // makes folder disappear
}

#pragma mark - Helpers

- (CGFloat)heightForSection:(NSInteger)section
{
	CGFloat height = 0;
	CGFloat numItems = [self.collectionView numberOfItemsInSection:section];
	NSInteger numRows = ceil(numItems / [self.cellsPerRowInSection[@( section )] integerValue]);
	height += (self.cellSize.height + self.interItemSpacingY) * numRows; // previous rows
	height += self.headerSize.height + self.interItemSpacingY; // header
	height += self.footerSize.height + self.interItemSpacingY; // footer
	
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( section )];
	if (visibleFolder)
	{
		UICollectionViewLayoutAttributes * folderAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind atIndexPath:visibleFolder];
		
		height += folderAttributes.frame.size.height + (self.interItemSpacingY * 2);
	}
	
	return height;
}


#pragma mark - UICollectionViewLayout methods

- (void)prepareLayout
{
	[super prepareLayout];

	NSMutableDictionary * newLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * cellLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * headerLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * footerLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * folderLayoutDictionary = [NSMutableDictionary dictionary];
//	NSMutableDictionary * decorationLayoutDictionary = [NSMutableDictionary dictionary];

	NSInteger numSections = [self.collectionView numberOfSections];
	self.cellsPerRowInSection = [NSMutableDictionary dictionaryWithCapacity:numSections];

	for(NSInteger section = 0; section < numSections; section++)
	{
		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];

		self.cellsPerRowInSection[@( section )] = @( floor( (self.collectionView.bounds.size.width + self.interItemSpacingX) / (self.cellSize.width + self.interItemSpacingX)) );

		for(NSInteger item = 0; item < numItems; item++)
		{
			NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:section];

			// Header
			if (indexPath.item == 0)
			{
				UICollectionViewLayoutAttributes * headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind atIndexPath:indexPath];

				if (headerAttributes)
				{
					[headerLayoutDictionary setObject:headerAttributes forKey:indexPath];
				}
            }

			// Cell
			UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			[cellLayoutDictionary setObject:attributes forKey:indexPath];

			// Folder
			UICollectionViewLayoutAttributes * folderAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind atIndexPath:indexPath];
			if (folderAttributes)
			{
				[folderLayoutDictionary setObject:folderAttributes forKey:indexPath];
			}
			
			// TODO: figure out decorations
//			// Decorations
//			UICollectionViewLayoutAttributes * decorationAttributes = [self layoutAttributesForDecorationViewOfKind:RBCollectionViewInfoFolderDecorationKind atIndexPath:indexPath];
//			
//			if (decorationAttributes)
//			{
//				[decorationLayoutDictionary setObject:decorationAttributes forKey:indexPath];
//				[self.decorations setObject:decorationAttributes forKey:indexPath];
//			}

			// Footer
			if(item == numItems - 1)
			{
				UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind atIndexPath:indexPath];

				if (footerAttributes)
				{
					[footerLayoutDictionary setObject:footerAttributes forKey:indexPath];
				}
			}
		}
	}

	newLayoutDictionary[RBCollectionViewInfoFolderCellKind] = cellLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderFolderKind] = folderLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderHeaderKind] = headerLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderFooterKind] = footerLayoutDictionary;

    self.layoutInformation = newLayoutDictionary;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

	CGRect itemFrame = CGRectZero;
	itemFrame.size = self.cellSize;

	// TODO: move all this into prepare
	NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
	CGFloat totalWidthUsed = cellsPerRowInSection * self.cellSize.width;
	CGFloat emptySpace = self.collectionView.bounds.size.width - totalWidthUsed;
	CGFloat rightPadding = emptySpace / (cellsPerRowInSection - 1);
	CGFloat deltaX = self.cellSize.width + rightPadding;

	itemFrame.origin.x = deltaX * (indexPath.row % cellsPerRowInSection);
	itemFrame.origin.y = (self.cellSize.height * (indexPath.row / cellsPerRowInSection)) + (self.interItemSpacingY * (indexPath.row / cellsPerRowInSection));

	// Do this for all sections before us
	for (int i = 0; i < indexPath.section; i++)
	{
		itemFrame.origin.y += [self heightForSection:i];
	}

	// Add in header height if needed
	if (self.headerSize.height > 0)
	{
		itemFrame.origin.y += self.headerSize.height + self.interItemSpacingY;
	}

	// If cell intersects visible folder for section bump it below folder
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];

	if (visibleFolder)
	{
		UICollectionViewLayoutAttributes * folderAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind atIndexPath:visibleFolder];

		if (CGRectGetMinY(itemFrame) >= CGRectGetMinY(folderAttributes.frame))
		{
			itemFrame.origin.y += folderAttributes.frame.size.height + self.interItemSpacingY;
		}
	}

	attributes.frame = itemFrame;

    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

	CGRect viewRect = CGRectZero;

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		viewRect.origin.y = 0;
		if (indexPath.section != 0)
		{
			// Do this for all sections before us
			for (int i = 0; i < indexPath.section; i++)
			{
				viewRect.origin.y += [self heightForSection:i];
			}
		}
		
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.headerSize.width / 2);
		viewRect.size = self.headerSize;
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		// Do this for all sections including our own
		for (int i = 0; i <= indexPath.section; i++)
		{
			viewRect.origin.y += [self heightForSection:i];
		}

		// remove accidental addition of our own footer in [heightForSection:]
		viewRect.origin.y -= self.footerSize.height + self.interItemSpacingY;
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.footerSize.width / 2);
		viewRect.size = self.footerSize;
	}

	if (kind == RBCollectionViewInfoFolderFolderKind)
	{
		// Do this for all sections before us
		for (int i = 0; i < indexPath.section; i++)
		{
			viewRect.origin.y += [self heightForSection:i];
		}
		
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
		NSInteger row = (indexPath.row / cellsPerRowInSection);
		
		viewRect.origin.y += (self.cellSize.height * (1 + row)) + (self.interItemSpacingY * row);
		viewRect.origin.y += self.headerSize.height + (self.interItemSpacingY * 2);
		viewRect.size.height = self.folderHeight;
		viewRect.size.width = self.collectionView.bounds.size.width;
	}

	attributes.frame = viewRect;

	return attributes;
}

// TODO: figure out decorations
//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
//{
//	UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:decorationViewKind withIndexPath:indexPath];
//	
//	CGRect decorationRect = CGRectZero;
//    
//	// Do this for all sections before us
//	for (int i = 0; i < indexPath.section; i++)
//	{
//		decorationRect.origin.y += [self heightForSection:i];
//	}
//	
//	NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
//	NSInteger row = (indexPath.row / cellsPerRowInSection);
//	
//	decorationRect.origin.y += (self.cellSize.height * (1 + row)) + (self.interItemSpacingY * row);
//	decorationRect.origin.y += self.headerSize.height + (self.interItemSpacingY * 2);
//	decorationRect.size.height = self.folderHeight;
//	decorationRect.size.width = self.collectionView.bounds.size.width;
//	
//	// pull decoration over cell
//	decorationRect.origin.y -= self.interItemSpacingY * 2;
//	
//	attributes.frame = decorationRect;
//	attributes.zIndex = 100;
//    
//    return attributes;
//}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray * attributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];

	[self.layoutInformation enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {

		[elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *layoutAttributes, BOOL *innerStop) {

			if (CGRectIntersectsRect(rect, layoutAttributes.frame))
			{
				// Only add folder if it's the visible folder for the section
				if (elementIdentifier == RBCollectionViewInfoFolderFolderKind && [indexPath isEqual:self.visibleFolderInSection[@( indexPath.section )]] == NO)
					return;

				[attributes addObject:layoutAttributes];
			}
		}];
	}];


	// TODO: figure out decorations
	// Add our decoration views to open folders
//	[self.decorations enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *layoutAttributes, BOOL *stop) {
//		
//		if (CGRectIntersectsRect(rect, layoutAttributes.frame))
//		{
//			if ([indexPath isEqual:self.visibleFolderInSection[@( indexPath.section )]])
//				[attributes addObject:layoutAttributes];
//		}
//	}];

	// TODO: implement stickyHeaders
//	if (self.stickyHeader == NO)
//	{
//		return attributes;
//	}
//
//	[attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * layoutAttributes, NSUInteger idx, BOOL *stop) {
//		if (layoutAttributes.representedElementKind == RBCollectionViewInfoFolderHeaderKind)
//		{
//			layoutAttributes.zIndex = 1024;
//
//			CGFloat top = MAX(layoutAttributes.frame.origin.y, self.collectionView.contentOffset.y);
//			CGFloat left = layoutAttributes.frame.origin.x;
//			CGFloat width = self.collectionView.bounds.size.width;
//			CGFloat height = layoutAttributes.frame.size.height;
//
//			NSInteger section = layoutAttributes.indexPath.section;
//			CGFloat bottomY = [self bottomYOfSection:section];
//			top = MIN(top, bottomY - height);
//
//			layoutAttributes.frame = CGRectMake(left, top, width, height);
//		}
//	}];

	return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
//    if (self.stickyHeader)
//    {
//        return YES;
//    }

    if (newBound.size.width != self.collectionView.bounds.size.width)
    {
        return YES;
    }

    return NO;
}

- (CGSize)collectionViewContentSize
{
	CGSize contentSize = CGSizeMake(self.collectionView.bounds.size.width, 0);

	// Do this for all sections
	NSInteger numSections = [self.collectionView numberOfSections];
	for (int i = 0; i < numSections; i++)
	{
		contentSize.height += [self heightForSection:i];
	}
	
	return contentSize;
}

// TODO: figure out how to make appearing supplimentary view animate with the layout movement
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
//{
//	UICollectionViewLayoutAttributes * attributes = [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
//	
//	if (elementKind == RBCollectionViewInfoFolderFolderKind)
//	{
//		CGRect frame = attributes.frame;
//		frame.size.height = 0;
//		attributes.frame = frame;
//	}
//	
//	return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
//{
//	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
//	
//	if (elementKind == RBCollectionViewInfoFolderFolderKind)
//	{
//		CGRect frame = attributes.frame;
//		frame.size.height = 0;
//		attributes.frame = frame;
//	}
//	
//	return attributes;
//}

@end
