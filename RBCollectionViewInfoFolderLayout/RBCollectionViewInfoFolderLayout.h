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

@interface RBCollectionViewInfoFolderDimple : UICollectionReusableView

@property (strong, nonatomic) UIColor * color;

@end

@interface RBCollectionViewInfoFolderLayout : UICollectionViewLayout

@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) CGSize headerSize;
@property (assign, nonatomic) CGSize footerSize;
@property (assign, nonatomic) CGFloat folderHeight;
@property (assign, nonatomic) CGFloat interItemSpacingY;
@property (assign, nonatomic) CGFloat interItemSpacingX;

- (void)toggleFolderViewForIndexPath:(NSIndexPath *)indexPath;

@end
