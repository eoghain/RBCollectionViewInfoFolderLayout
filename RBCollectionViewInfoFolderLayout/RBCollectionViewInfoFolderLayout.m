//
//  RBCollectionViewInfoFolderLayout.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import "RBCollectionViewInfoFolderLayout.h"

static NSString *const RBCollectionViewInfoFolderCellKind = @"RBCollectionViewInfoFolderCellKind";
NSString *const RBCollectionViewInfoFolderDimpleKind = @"RBCollectionViewInfoFolderDimpleKind";
NSString *const RBCollectionViewInfoFolderHeaderKind = @"RBCollectionViewInfoFolderHeaderKind";
NSString *const RBCollectionViewInfoFolderFooterKind = @"RBCollectionViewInfoFolderFooterKind";
NSString *const RBCollectionViewInfoFolderFolderKind = @"RBCollectionViewInfoFolderFolderKind";


@implementation RBCollectionViewInfoFolderDimple

+ (NSString *)kind
{
    return RBCollectionViewInfoFolderDimpleKind;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.color = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	UIBezierPath* polygonPath = [UIBezierPath bezierPath];
	[polygonPath moveToPoint: CGPointMake(rect.size.width/2, -0.5)];
	[polygonPath addLineToPoint: CGPointMake(rect.size.width, rect.size.height)];
	[polygonPath addLineToPoint: CGPointMake(0, rect.size.height)];
	[polygonPath closePath];
	[self.color setFill];
	[polygonPath fill];
}

@end

@interface RBCollectionViewInfoFolderLayout ()

@property (strong, nonatomic) NSMutableDictionary * layoutInformation;
@property (strong, nonatomic) NSMutableDictionary * cellsPerRowInSection;
@property (strong, nonatomic) NSMutableDictionary * visibleFolderInSection;

@property (strong, nonatomic) NSMutableArray * insertIndexPaths;
@property (strong, nonatomic) NSMutableArray * deleteIndexPaths;
@property (strong, nonatomic) NSMutableArray * reloadIndexPaths;

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
	self.stickyHeaders = NO;
	self.cellSize = CGSizeMake(200, 200);
	self.headerSize = CGSizeZero;
	self.footerSize = CGSizeZero;
	self.folderHeight = 100.0;
	self.interItemSpacingY = 5.0;
	self.interItemSpacingX = 5.0;

	self.visibleFolderInSection = [NSMutableDictionary dictionary];
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
	NSInteger selectedFolderRow = [self rowForIndexPath:indexPath];
	NSInteger openFolderRow = (visibleFolder) ? [self rowForIndexPath:visibleFolder] : selectedFolderRow;

	// Ugly Hack to get folders to animate closeing
	/*
	 * A. if user selected an item in a different row than currently open folder's row
	 *
	 * B. if user selected the item that has folder already open
	 *		1. close folder by shrinking height
	 *		2. re-size folder so it can be open again later
	 */
	if (visibleFolder)
	{
		if ([indexPath isEqual:visibleFolder] || selectedFolderRow != openFolderRow) // A & B
		{
			UICollectionViewLayoutAttributes * attributes = self.layoutInformation[RBCollectionViewInfoFolderFolderKind][visibleFolder];

			for (UIView *subview in [self.collectionView subviews])
			{
				// Find subview for our visible folder
				if ([subview isKindOfClass:[UICollectionReusableView class]] && CGRectEqualToRect(subview.frame, attributes.frame))
				{
					CGRect origFrame = subview.frame;

					// Close folder A & B.1
					[UIView animateWithDuration:0.295 // Just under .3 to try and match
										  delay:0.0
										options:UIViewAnimationOptionCurveEaseInOut
									 animations:^{
						CGRect frame = subview.frame;

						if (selectedFolderRow < openFolderRow)
							frame.origin.y += frame.size.height;

						frame.size.height = 0;
						subview.frame = frame;
					} completion:^(BOOL finished) {
						if ([indexPath isEqual:visibleFolder]) // B.2
						{
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
								subview.frame = origFrame;
							});
						}
					}];
				}
			}
		}
	}

	if ([visibleFolder isEqual:indexPath])
	{
		[self.visibleFolderInSection removeObjectForKey:@( indexPath.section )];
	}
	else
	{
		self.visibleFolderInSection[@( indexPath.section )] = indexPath;
	}

	// If we are opening a row below an already open row reload the visible item
	if (selectedFolderRow > openFolderRow)
	{
		[self.collectionView reloadItemsAtIndexPaths:@[ visibleFolder ]];
	}
	else // reload the selected item
	{
		[self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
	}

	[self invalidateLayout]; // makes closed folder stay disappeared
}

#pragma mark - Helpers

- (NSInteger)rowForIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath == nil)
		return -1;

	NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
	NSInteger row = (indexPath.row / cellsPerRowInSection);

	return row;
}

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
	NSMutableDictionary * dimpleLayoutDictionary = [NSMutableDictionary dictionary];

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

			// Dimples
			UICollectionViewLayoutAttributes * dimpleAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderDimpleKind atIndexPath:indexPath];
			
			if (dimpleAttributes)
			{
				[dimpleLayoutDictionary setObject:dimpleAttributes forKey:indexPath];
			}

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
	newLayoutDictionary[RBCollectionViewInfoFolderDimpleKind] = dimpleLayoutDictionary;

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

	// Do this for all sections before us
	for (int i = 0; i < indexPath.section; i++)
	{
		viewRect.origin.y += [self heightForSection:i];
	}

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.headerSize.width / 2);
		viewRect.size = self.headerSize;
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		// Add our own sections height
		viewRect.origin.y += [self heightForSection:indexPath.section];

		// remove accidental addition of our own footer in [heightForSection:]
		viewRect.origin.y -= self.footerSize.height + self.interItemSpacingY;
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.footerSize.width / 2);
		viewRect.size = self.footerSize;
	}

	if (kind == RBCollectionViewInfoFolderFolderKind)
	{
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
		NSInteger row = (indexPath.row / cellsPerRowInSection);
		
		viewRect.origin.y += (self.cellSize.height * (1 + row)) + (self.interItemSpacingY * row);
		viewRect.origin.y += self.headerSize.height + (self.interItemSpacingY * 2);
		viewRect.size.height = self.folderHeight;
		viewRect.size.width = self.collectionView.bounds.size.width;
	}

	if (kind == RBCollectionViewInfoFolderDimpleKind)
	{
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
		NSInteger row = (indexPath.row / cellsPerRowInSection);

		CGFloat totalWidthUsed = cellsPerRowInSection * self.cellSize.width;
		CGFloat emptySpace = self.collectionView.bounds.size.width - totalWidthUsed;
		CGFloat rightPadding = emptySpace / (cellsPerRowInSection - 1);
		CGFloat deltaX = self.cellSize.width + rightPadding;

		CGFloat additionalHeight = 10;
		CGFloat height = self.interItemSpacingY + additionalHeight;
		CGFloat width = (height / 3) * 5;

		viewRect.origin.x = deltaX * (indexPath.row % cellsPerRowInSection) + (self.cellSize.width / 2) - (width / 2);
		viewRect.origin.y += (self.cellSize.height * (1 + row)) + (self.interItemSpacingY * row);
		viewRect.origin.y += self.headerSize.height + self.interItemSpacingY;
		viewRect.size.height = height;
		viewRect.size.width = width;

		// pull dimple over cell
		viewRect.origin.y -= additionalHeight;

		// make sure dimple appears over cell
		attributes.zIndex = 100;
	}

	attributes.frame = viewRect;

	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray * attributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];

	[self.layoutInformation enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {

		[elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *layoutAttributes, BOOL *innerStop) {

			if (CGRectIntersectsRect(rect, layoutAttributes.frame) || [elementIdentifier isEqualToString:RBCollectionViewInfoFolderHeaderKind])
			{
				// Only add folder if it's the visible folder for the section
				if (elementIdentifier == RBCollectionViewInfoFolderFolderKind && [indexPath isEqual:self.visibleFolderInSection[@( indexPath.section )]] == NO)
					return;

				// Only add dimple if the folder is visible
				if (elementIdentifier == RBCollectionViewInfoFolderDimpleKind && [indexPath isEqual:self.visibleFolderInSection[@( indexPath.section )]] == NO)
					return;

				[attributes addObject:layoutAttributes];
			}
		}];
	}];

	// TODO: implement stickyHeaders
	if (self.stickyHeaders == NO)
	{
		return attributes;
	}

	[attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * layoutAttributes, NSUInteger idx, BOOL *stop) {
		if (layoutAttributes.representedElementKind == RBCollectionViewInfoFolderHeaderKind)
		{
			layoutAttributes.zIndex = 1024;

			CGFloat top = MAX(layoutAttributes.frame.origin.y, self.collectionView.contentOffset.y);
			CGFloat left = layoutAttributes.frame.origin.x;
			CGFloat width = self.collectionView.bounds.size.width;
			CGFloat height = layoutAttributes.frame.size.height;

			NSInteger section = layoutAttributes.indexPath.section;
			CGFloat bottomY = [self heightForSection:section] + layoutAttributes.frame.origin.y;
			top = MIN(top, bottomY - height);

			layoutAttributes.frame = CGRectMake(left, top, width, height);
		}
	}];

	return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    if (self.stickyHeaders)
    {
        return YES;
    }

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
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
	// Keep track of insert and delete index paths
	[super prepareForCollectionViewUpdates:updateItems];

	self.deleteIndexPaths = [NSMutableArray array];
	self.insertIndexPaths = [NSMutableArray array];
	self.reloadIndexPaths = [NSMutableArray array];

	for (UICollectionViewUpdateItem *update in updateItems)
	{
		if (update.updateAction == UICollectionUpdateActionDelete)
		{
			[self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionInsert)
		{
			[self.insertIndexPaths addObject:update.indexPathAfterUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionReload)
		{
			[self.reloadIndexPaths addObject:update.indexPathAfterUpdate];
		}
	}
}

- (void)finalizeCollectionViewUpdates
{
	[super finalizeCollectionViewUpdates];

	// release the insert and delete index paths
	self.deleteIndexPaths = nil;
	self.insertIndexPaths = nil;
	self.reloadIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes;

	if ([self.reloadIndexPaths containsObject:itemIndexPath])
	{
		attributes = self.layoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath];
	}
	else
	{
		attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
	}

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

	if (!attributes) // If cell is moving off the screen attributes will be nil, but we want it to animate
		attributes = self.layoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

@end
