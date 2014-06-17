//
//  RBCollectionViewInfoFolderLayout.h
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const RBCollectionViewInfoFolderHeaderKind;
FOUNDATION_EXPORT NSString *const RBCollectionViewInfoFolderFooterKind;
FOUNDATION_EXPORT NSString *const RBCollectionViewInfoFolderFolderKind;
FOUNDATION_EXPORT NSString *const RBCollectionViewInfoFolderDimpleKind;

@class RBCollectionViewInfoFolderLayout;

@protocol RBCollectionViewInfoFolderLayoutDelegate <NSObject>

/**
 *  Height of the folder for an item
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param indexpath            indexPath of item
 *
 *  @return the height of the header
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout heightForFolderAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Size of the header for a section (0 for no header in this section)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param section              section index
 *
 *  @return the size of the header
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForHeaderInSection:(NSInteger)section;

/**
 *  Size of the footer for a section (0 for no footer in this section)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param section              section index
 *
 *  @return the size of the footer
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForFooterInSection:(NSInteger)section;

@end

@interface RBCollectionViewInfoFolderDimple : UICollectionReusableView

@property (strong, nonatomic) UIColor * color;

@end

@interface RBCollectionViewInfoFolderLayout : UICollectionViewLayout

/**
 * Stick the header to top until section goes out of scope
 */
@property (assign, nonatomic) BOOL stickyHeaders;

/**
 * Size of the cells
 */
@property (assign, nonatomic) CGSize cellSize;

/**
 * Vertical spaceing between cells
 */

@property (assign, nonatomic) CGFloat interItemSpacingY;
/**
 * Horizontal spaceing between cells
 */
@property (assign, nonatomic) CGFloat interItemSpacingX;

/**
 * Open/Close the folder view at the given indexPath
 * Will close any other open folder in the same section
 */
- (void)toggleFolderViewForIndexPath:(NSIndexPath *)indexPath;

/**
 * Close the folder at the given indexPath if it's open
 */
- (void)closeFolderViewForIndexPath:(NSIndexPath *)indexPath;

/**
 * Close any folder in given section
 */
- (void)closeOpenFolderInSection:(NSInteger)section;

/**
 * Close all open folders
 */
- (void)closeAllOpenFolders;

/**
 * IndexPath for the item that is associated with the folder view at a given point
 *
 * Useful for when you need to place buttons in your folder to act on the item.
 * Don't forget to translate the point into the collectionViews coordinate space.
 */
- (NSIndexPath *)indexPathForItemAssociatedWithFolderAtPoint:(CGPoint)point;

@end
