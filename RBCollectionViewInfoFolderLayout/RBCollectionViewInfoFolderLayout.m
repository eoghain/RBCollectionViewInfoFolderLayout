//
//  RBCollectionViewInfoFolderLayout.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import "RBCollectionViewInfoFolderLayout.h"

static NSString *const RBCollectionViewInfoFolderCellKind = @"RBCollectionViewInfoFolderCellKind";
NSString *const RBCollectionViewInfoFolderHeaderKind = @"RBCollectionViewInfoFolderHeaderKind";
NSString *const RBCollectionViewInfoFolderFooterKind = @"RBCollectionViewInfoFolderFooterKind";
NSString *const RBCollectionViewInfoFolderFolderKind = @"RBCollectionViewInfoFolderFolderKind";

@interface RBCollectionViewInfoFolderLayout ()

@property (strong, nonatomic) NSMutableDictionary * layoutInformation;
@property (strong, nonatomic) NSMutableDictionary * headers;
@property (strong, nonatomic) NSMutableDictionary * footers;
@property (strong, nonatomic) NSMutableDictionary * folders;
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

#pragma mark - Folder Display Methods

- (void)toggleFolderViewForIndexPath:(NSIndexPath *)indexPath
{
	NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];

	if (visibleFolder == indexPath)
	{
		[self.visibleFolderInSection removeObjectForKey:@( indexPath.section )];
	}
	else
	{
		self.visibleFolderInSection[@( indexPath.section )] = indexPath;
	}

	[self invalidateLayout];
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

	NSInteger numSections = [self.collectionView numberOfSections];
	self.headers = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.footers = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.folders = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.cellsPerRowInSection = [NSMutableDictionary dictionaryWithCapacity:numSections];

	for(NSInteger section = 0; section < numSections; section++)
	{
		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];

		self.cellsPerRowInSection[@( section )] = @( floor(self.collectionView.bounds.size.width / (self.cellSize.width + self.interItemSpacingX)) );

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
					[self.headers setObject:headerAttributes forKey:indexPath];
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
				[self.folders setObject:folderAttributes forKey:indexPath];
			}

			// Footer
			if(item == numItems - 1)
			{
				UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind atIndexPath:indexPath];

				if (footerAttributes)
				{
					[footerLayoutDictionary setObject:footerAttributes forKey:indexPath];
					[self.footers setObject:footerAttributes forKey:indexPath];
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

	// Add previous section height
	NSInteger numRows = 0;
	for (int i = 0; i < indexPath.section; i++)
	{
		itemFrame.origin.y += self.headerSize.height + self.interItemSpacingY;
		NSInteger numItems = [self.collectionView numberOfItemsInSection:i];
		numRows += numItems / [self.cellsPerRowInSection[@( i )] integerValue];
	}

	itemFrame.origin.y += (self.cellSize.height + self.interItemSpacingY) * numRows;

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

		NSLog(@"indexPath: %@ itemFrame:%@ folderFrame:%@", indexPath, NSStringFromCGRect(itemFrame), NSStringFromCGRect(folderAttributes.frame));
		if (CGRectGetMinY(itemFrame) >= CGRectGetMinY(folderAttributes.frame))
		{
			itemFrame.origin.y += CGRectGetHeight(folderAttributes.frame);
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
//		if (indexPath.section != 0)
//		{
//			NSInteger numRows = 0;
//			for (int i = 0; i < indexPath.section; i++)
//			{
//				NSInteger numItems = [self.collectionView numberOfItemsInSection:indexPath.section];
//				numRows += numItems / [self.cellsPerRowInSection[@( indexPath.section )] integerValue];
//			}
//
//			viewRect.origin.y = self.cellSize.height * numRows;
//		}
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.headerSize.width / 2);
		viewRect.size = self.headerSize;
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		NSInteger numRows = 0;
		for (int i = 0; i <= indexPath.section; i++)
		{
			viewRect.origin.y += self.headerSize.height + self.interItemSpacingY;
			NSInteger numItems = [self.collectionView numberOfItemsInSection:i];
			numRows += numItems / [self.cellsPerRowInSection[@( i )] integerValue];
		}

		viewRect.origin.y += (self.cellSize.height + self.interItemSpacingY) * numRows;
		viewRect.origin.x = CGRectGetMidX(self.collectionView.bounds) - (self.footerSize.width / 2);
		viewRect.size = self.footerSize;

		NSIndexPath * visibleFolder = self.visibleFolderInSection[@( indexPath.section )];
		if (visibleFolder)
		{
			UICollectionViewLayoutAttributes * folderAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind atIndexPath:visibleFolder];

			if (CGRectGetMinY(viewRect) >= CGRectGetMinY(folderAttributes.frame))
			{
				viewRect.origin.y += CGRectGetHeight(folderAttributes.frame);
			}
		}

	}

	if (kind == RBCollectionViewInfoFolderFolderKind)
	{
		NSInteger cellsPerRowInSection = [self.cellsPerRowInSection[@( indexPath.section )] integerValue];

		viewRect.origin.y = (self.cellSize.height * (1 + (indexPath.row / cellsPerRowInSection))) + (self.interItemSpacingY * (indexPath.row / cellsPerRowInSection));
		viewRect.size.height = self.folderHeight;
		viewRect.size.width = self.collectionView.bounds.size.width;

		viewRect.origin.y += (self.headerSize.height + self.interItemSpacingY) * (indexPath.section + 1);
	}

	attributes.frame = viewRect;

	return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray * attributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];

	NSLog(@"visibleFolders:%@", self.visibleFolderInSection);
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

	NSInteger numSections = [self.collectionView numberOfSections];
	NSInteger numRows = 0;
	for (int i = 0; i < numSections; i++)
	{
		contentSize.height += self.headerSize.height + self.interItemSpacingY + self.footerSize.height;
		NSInteger numItems = [self.collectionView numberOfItemsInSection:i];
		numRows += numItems / [self.cellsPerRowInSection[@( i )] integerValue];
	}

	contentSize.height += numRows * (self.cellSize.height + self.interItemSpacingY);

	return contentSize;
}

@end
