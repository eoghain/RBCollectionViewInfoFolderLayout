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
@property (strong, nonatomic) NSMutableDictionary * previousLayoutInformation;
@property (strong, nonatomic) NSMutableDictionary * cellsPerRowInSection;
@property (strong, nonatomic) NSMutableDictionary * visibleFolderInSection;
@property (strong, nonatomic) NSMutableDictionary * deltaXInSection;

@property (strong, nonatomic) NSMutableArray * insertIndexPaths;
@property (strong, nonatomic) NSMutableArray * deleteIndexPaths;
@property (strong, nonatomic) NSMutableArray * reloadIndexPaths;

@property (strong, nonatomic) NSMutableDictionary * headerSizes;
@property (strong, nonatomic) NSMutableDictionary * footerSizes;
@property (strong, nonatomic) NSMutableDictionary * folderHeights;


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

#pragma mark - Interface

- (void)closeAllOpenFolders
{
	NSDictionary * openFolders = [self.visibleFolderInSection copy];

	[openFolders enumerateKeysAndObjectsUsingBlock:^(id key, NSIndexPath * indexPath, BOOL *stop) {
		[self toggleFolderViewForIndexPath:indexPath];
	}];
}

- (void)closeOpenFolderInSection:(NSInteger)section
{
	NSDictionary * openFolders = [self.visibleFolderInSection copy];

	[openFolders enumerateKeysAndObjectsUsingBlock:^(id key, NSIndexPath * indexPath, BOOL *stop) {
		if (indexPath.section == section)
			[self toggleFolderViewForIndexPath:indexPath];
	}];
}

- (void)closeFolderViewForIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];

	if ([indexPath isEqual:visibleFolder])
		[self toggleFolderViewForIndexPath:indexPath];
}

- (void)toggleFolderViewForIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];
	NSInteger selectedFolderRow = [self rowForIndexPath:indexPath];
	NSInteger openFolderRow = (visibleFolder) ? [self rowForIndexPath:visibleFolder] : selectedFolderRow;

	if ([visibleFolder isEqual:indexPath])
	{
		[self.visibleFolderInSection removeObjectForKey:@( indexPath.section )];
	}
	else
	{
		self.visibleFolderInSection[@( indexPath.section )] = indexPath;

		UICollectionViewLayoutAttributes * attributes = self.layoutInformation[RBCollectionViewInfoFolderFolderKind][indexPath];
		CGRect scrollFrame = attributes.frame;
		scrollFrame.origin.y += attributes.frame.size.height;
		scrollFrame.size.height = 5;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self.collectionView scrollRectToVisible:scrollFrame animated:YES];
		});
	}

	// If we are opening a row below an already open row reload the visible item
	if (selectedFolderRow > openFolderRow)
	{
		[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:visibleFolder.section]];
	}
	else // reload the selected item
	{
		[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
	}
}

- (NSIndexPath *)indexPathForItemAssociatedWithFolderAtPoint:(CGPoint)point
{
	__block NSIndexPath * indexPath = nil;
	[self.visibleFolderInSection enumerateKeysAndObjectsUsingBlock:^(id key, NSIndexPath * obj, BOOL *stop) {
		UICollectionViewLayoutAttributes * attributes = self.layoutInformation[RBCollectionViewInfoFolderFolderKind][obj];
		if (CGRectContainsPoint(attributes.frame, point))
		{
			indexPath = obj;
			*stop = YES;
		}
	}];
		
	return indexPath;
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

- (CGSize)sizeForHeaderInSection:(NSInteger)section
{
	return [((NSValue *)self.headerSizes[@( section )]) CGSizeValue];
}

- (CGSize)sizeForFooterInSection:(NSInteger)section
{
	return [((NSValue *)self.footerSizes[@( section )]) CGSizeValue];
}

- (CGFloat)heightForFolderAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.folderHeights[indexPath] floatValue];
}

- (CGFloat)heightForSection:(NSInteger)section
{
	CGFloat height = 0;
	CGFloat numItems = [self.collectionView numberOfItemsInSection:section];
	NSInteger numRows = ceil(numItems / [self.cellsPerRowInSection[@( section )] integerValue]);
	height += (self.cellSize.height + self.interItemSpacingY) * numRows; // previous rows

	CGSize headerSize = [self sizeForHeaderInSection:section];
	if (headerSize.height > 0)
		height += headerSize.height + self.interItemSpacingY;

	CGSize footerSize = [self sizeForFooterInSection:section];
	if (footerSize.height > 0)
		height += footerSize.height + self.interItemSpacingY;
	
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

	id delegate = self.collectionView.delegate;

	NSMutableDictionary * newLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * cellLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * headerLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * footerLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * folderLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary * dimpleLayoutDictionary = [NSMutableDictionary dictionary];

	NSInteger numSections = [self.collectionView numberOfSections];
	self.cellsPerRowInSection = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.headerSizes = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.footerSizes = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.folderHeights = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.deltaXInSection = [NSMutableDictionary dictionaryWithCapacity:numSections];

	for(NSInteger section = 0; section < numSections; section++)
	{
		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];

		self.cellsPerRowInSection[@( section )] = @( floor( (self.collectionView.bounds.size.width + self.interItemSpacingX) / (self.cellSize.width + self.interItemSpacingX)) );


		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( section )] integerValue];
		CGFloat totalWidthUsed = cellsPerRowInSection * self.cellSize.width;
		CGFloat emptySpace = self.collectionView.bounds.size.width - totalWidthUsed;
		CGFloat rightPadding = emptySpace / MAX((cellsPerRowInSection - 1), 1);
		self.deltaXInSection[@( section )] = @( self.cellSize.width + rightPadding );

		for(NSInteger item = 0; item < numItems; item++)
		{
			NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:section];

			// Header ------------------------------------------------------------
			if (indexPath.item == 0)
			{
				self.headerSizes[@( section )] = [NSValue valueWithCGSize:[delegate collectionView:self.collectionView layout:self sizeForHeaderInSection:section]];

				UICollectionViewLayoutAttributes * headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind atIndexPath:indexPath];
				[headerLayoutDictionary setObject:headerAttributes forKey:indexPath];
            }

			// Cell ------------------------------------------------------------
			UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			[cellLayoutDictionary setObject:attributes forKey:indexPath];

			// Folder ------------------------------------------------------------
			self.folderHeights[indexPath] = @( [delegate collectionView:self.collectionView layout:self heightForFolderAtIndexPath:indexPath] );

			UICollectionViewLayoutAttributes * folderAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind atIndexPath:indexPath];
			[folderLayoutDictionary setObject:folderAttributes forKey:indexPath];

			// Dimples ------------------------------------------------------------
			UICollectionViewLayoutAttributes * dimpleAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderDimpleKind atIndexPath:indexPath];
			[dimpleLayoutDictionary setObject:dimpleAttributes forKey:indexPath];

			// Footer ------------------------------------------------------------
			if(item == numItems - 1)
			{
				self.footerSizes[@( section )] = [NSValue valueWithCGSize:[delegate collectionView:self.collectionView layout:self sizeForFooterInSection:section]];

				UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind atIndexPath:indexPath];
				[footerLayoutDictionary setObject:footerAttributes forKey:indexPath];
			}
		}
	}

	newLayoutDictionary[RBCollectionViewInfoFolderCellKind] = cellLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderFolderKind] = folderLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderHeaderKind] = headerLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderFooterKind] = footerLayoutDictionary;
	newLayoutDictionary[RBCollectionViewInfoFolderDimpleKind] = dimpleLayoutDictionary;

	// Store last layout so our animations work
	self.previousLayoutInformation = self.layoutInformation;
    self.layoutInformation = newLayoutDictionary;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

	CGRect itemFrame = CGRectZero;
	itemFrame.size = self.cellSize;

	// TODO: move all this into prepare
	NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
	CGFloat deltaX = [self.deltaXInSection[@( indexPath.section )] floatValue];

	if (cellsPerRowInSection == 1)
	{
		itemFrame.origin.x = (deltaX - self.cellSize.width) / 2;
	}
	else
	{
		itemFrame.origin.x = deltaX * (indexPath.row % cellsPerRowInSection);
	}

	itemFrame.origin.y = (self.cellSize.height * (indexPath.row / cellsPerRowInSection)) + (self.interItemSpacingY * (indexPath.row / cellsPerRowInSection));

	// Do this for all sections before us
	for (int i = 0; i < indexPath.section; i++)
	{
		itemFrame.origin.y += [self heightForSection:i];
	}

	// Add in header height if needed
	CGSize headerSize = [self sizeForHeaderInSection:indexPath.section];
	if (headerSize.height > 0)
		itemFrame.origin.y += headerSize.height + self.interItemSpacingY;

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

	CGSize headerSize = [self sizeForHeaderInSection:indexPath.section];
	CGSize footerSize = [self sizeForFooterInSection:indexPath.section];
	CGFloat folderHeight = [self heightForFolderAtIndexPath:indexPath];

	CGRect viewRect = CGRectZero;

	// Do this for all sections before us
	for (int i = 0; i < indexPath.section; i++)
	{
		viewRect.origin.y += [self heightForSection:i];
	}

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (headerSize.width / 2);
		viewRect.size = headerSize;
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		// Add our own sections height
		viewRect.origin.y += [self heightForSection:indexPath.section];

		// remove accidental addition of our own footer in [heightForSection:]
		if (footerSize.height > 0)
			viewRect.origin.y -= footerSize.height + self.interItemSpacingY;
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (footerSize.width / 2);
		viewRect.size = footerSize;
	}

	if (kind == RBCollectionViewInfoFolderFolderKind)
	{
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
		NSInteger row = (indexPath.row / cellsPerRowInSection);
		
		viewRect.origin.y += ((self.cellSize.height + self.interItemSpacingY) * (1 + row));
		if (headerSize.height > 0)
			viewRect.origin.y += headerSize.height + self.interItemSpacingY;
		viewRect.size.height = folderHeight;
		viewRect.size.width = self.collectionView.bounds.size.width;
	}

	if (kind == RBCollectionViewInfoFolderDimpleKind)
	{
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
		NSInteger row = (indexPath.row / cellsPerRowInSection);
		CGFloat deltaX = [self.deltaXInSection[@( indexPath.section )] floatValue];

		CGFloat additionalHeight = 10;
		CGFloat height = self.interItemSpacingY + additionalHeight;
		CGFloat width = (height / 3) * 5;

		if (cellsPerRowInSection == 1)
		{
			viewRect.origin.x = (deltaX - self.cellSize.width) / 2 + (self.cellSize.width / 2) - (width / 2);
		}
		else
		{
			viewRect.origin.x = deltaX * (indexPath.row % cellsPerRowInSection) + (self.cellSize.width / 2) - (width / 2);
		}
		viewRect.origin.y += ((self.cellSize.height + self.interItemSpacingY) * (1 + row));
		if (headerSize.height > 0)
			viewRect.origin.y += headerSize.height + self.interItemSpacingY;
		viewRect.size.height = height;
		viewRect.size.width = width;

		// pull dimple over cell
		viewRect.origin.y -= additionalHeight * 2;

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

	if (self.stickyHeaders == YES)
	{
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
	}

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
			dispatch_async(dispatch_get_main_queue(), ^{
				[self closeAllOpenFolders];
			});
			[self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionInsert)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self closeAllOpenFolders];
			});
			[self.insertIndexPaths addObject:update.indexPathAfterUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionReload)
		{
			[self.reloadIndexPaths addObject:update.indexPathAfterUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionMove)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self closeAllOpenFolders];
			});
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

	if (self.previousLayoutInformation[elementKind][elementIndexPath])
	{
		attributes = self.previousLayoutInformation[elementKind][elementIndexPath];
	}

	[self.reloadIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * reloadIndexPath, NSUInteger idx, BOOL *stop) {
		NSIndexPath * testIndexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:reloadIndexPath.section];

		if ([testIndexPath isEqual:reloadIndexPath] && reloadIndexPath.section == elementIndexPath.section)
		{
			// grow folder down from top edge
			if ([elementKind isEqualToString:RBCollectionViewInfoFolderFolderKind])
			{
				CGRect frame = attributes.frame;
				frame.size.height = 0;
				attributes.frame = frame;
			}

			// grow dimple away from folder towards cell
			if ([elementKind isEqualToString:RBCollectionViewInfoFolderDimpleKind])
			{
				CGRect frame = attributes.frame;
				frame.origin.y += frame.size.height;
				frame.size.height = 0;
				attributes.frame = frame;
			}
		}
	}];

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];

	if (self.previousLayoutInformation[elementKind][elementIndexPath])
	{
		attributes = self.layoutInformation[elementKind][elementIndexPath];
	}

	[self.reloadIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * reloadIndexPath, NSUInteger idx, BOOL *stop) {
		NSIndexPath * testIndexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:reloadIndexPath.section];

		if ([testIndexPath isEqual:reloadIndexPath] && reloadIndexPath.section == elementIndexPath.section)
		{
			// Collapse folder up into top edge
			if ([elementKind isEqualToString:RBCollectionViewInfoFolderFolderKind])
			{
				CGRect frame = attributes.frame;
				frame.size.height = 0;
				attributes.frame = frame;
			}

			// Shrink dimple down towards folder
			if ([elementKind isEqualToString:RBCollectionViewInfoFolderDimpleKind])
			{
				CGRect frame = attributes.frame;
				frame.origin.y += frame.size.height;
				frame.size.height = 0;
				attributes.frame = frame;
			}
		}
	}];

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];

	if (self.previousLayoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath])
	{
		attributes = self.previousLayoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath];
	}

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

	if (self.previousLayoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath])
	{
		attributes = self.layoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath];
	}

	if (!attributes) // If cell is moving off the screen attributes will be nil, but we want it to animate
		attributes = self.layoutInformation[RBCollectionViewInfoFolderCellKind][itemIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

@end
