//
//  ComicDataView.h
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/4/14.
//
//

#import <UIKit/UIKit.h>

@interface ComicDataView : UICollectionReusableView

@property (strong, nonatomic) UILabel * title;
@property (strong, nonatomic) UILabel * desc;
@property (strong, nonatomic) UILabel * upc;

+ (CGFloat)heightOfViewWithTitle:(NSString *)title description:(NSString *)desc upc:(NSString *)upc constrainedToSize:(CGSize)constrainedSize;

@end
