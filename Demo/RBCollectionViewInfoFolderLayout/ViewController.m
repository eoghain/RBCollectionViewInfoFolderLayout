//
//  ViewController.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import "ViewController.h"
#import "RBCollectionViewInfoFolderLayout.h"
#import "ComicData.h"
#import "ComicDataView.h"

@interface ViewController () <RBCollectionViewInfoFolderLayoutDelegate>

@property (nonatomic, strong) NSArray * dataKeys;
@property (nonatomic, strong) NSDictionary * data;
@property (nonatomic, strong) NSCache * imageCache;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.imageCache = [[NSCache alloc] init];

	RBCollectionViewInfoFolderLayout * layout = (id)self.collectionView.collectionViewLayout;
	layout.cellSize = CGSizeMake(216, 325);
	layout.interItemSpacingY = 10;
	layout.stickyHeaders = YES;

	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind withReuseIdentifier:@"header"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind withReuseIdentifier:@"footer"];
	[self.collectionView registerClass:[ComicDataView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind withReuseIdentifier:@"folder"];
	[self.collectionView registerClass:[RBCollectionViewInfoFolderDimple class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderDimpleKind withReuseIdentifier:@"dimple"];

	self.collectionView.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1.0];

	self.data = [ComicData data];
	self.dataKeys = [self.data allKeys];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.dataKeys count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.data[self.dataKeys[section]][@"results"] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView * reuseView;

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

		reuseView.backgroundColor = [UIColor whiteColor];

		UILabel * label = (id)[reuseView viewWithTag:1];
		if (label == nil)
		{
			label = [[UILabel alloc] init];
			label.tag = 1;
			label.frame = CGRectMake(0, 0, reuseView.frame.size.width, reuseView.frame.size.height);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.textAlignment = NSTextAlignmentCenter;
			[reuseView addSubview:label];
		}

		label.text = self.dataKeys[indexPath.section];
		label.textColor = [UIColor colorWithRed:0x33/250.0 green:0x33/250.0 blue:0x33/250.0 alpha:1.0];
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];

		reuseView.backgroundColor = [UIColor clearColor];

		UILabel * label = (id)[reuseView viewWithTag:1];
		if (label == nil)
		{
			label = [[UILabel alloc] init];
			label.tag = 1;
			label.frame = CGRectMake(0, 0, reuseView.frame.size.width, reuseView.frame.size.height);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.textAlignment = NSTextAlignmentCenter;
			[reuseView addSubview:label];
		}

		label.text = @"Data provided by Marvel. © 2014 Marvel";
	}

	if (kind == RBCollectionViewInfoFolderFolderKind)
	{
		ComicDataView * comicDataView = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"folder" forIndexPath:indexPath];

		comicDataView.backgroundColor = [UIColor colorWithRed:0x88/255.0 green:0xc2/255.0 blue:0xc4/255.0 alpha:1.0];

		UILabel * label = (id)[reuseView viewWithTag:1];
		if (label == nil)
		{
			label = [[UILabel alloc] init];
			label.tag = 1;
			label.frame = CGRectMake(0, 0, reuseView.frame.size.width, reuseView.frame.size.height);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.textAlignment = NSTextAlignmentCenter;
			[reuseView addSubview:label];
		}

		comicDataView.title.text = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"title"];
		comicDataView.desc.text = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"description"];
		comicDataView.upc.text = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"upc"];

		reuseView = comicDataView;
	}

	if (kind == RBCollectionViewInfoFolderDimpleKind)
	{
		RBCollectionViewInfoFolderDimple * dimple = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"dimple" forIndexPath:indexPath];

		dimple.color = [UIColor colorWithRed:0x88/255.0 green:0xc2/255.0 blue:0xc4/255.0 alpha:1.0];

		reuseView = dimple;
	}

	return reuseView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

	NSDictionary * data;
	data = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row];

	NSString * imagePath = data[@"thumbnail"][@"path"];
	imagePath = [imagePath stringByAppendingString:@"/portrait_incredible."];
	imagePath = [imagePath stringByAppendingString:data[@"thumbnail"][@"extension"]];
	NSURL * imageURL = [NSURL URLWithString:imagePath];

	if ([self.imageCache objectForKey:imageURL] == nil)
	{
		__weak typeof(self) weakSelf = self;
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
			dispatch_sync(dispatch_get_main_queue(), ^{
				[weakSelf.imageCache setObject:image forKey:imageURL];

				UIImageView * imageView = (id)[cell viewWithTag:1];
				[imageView setImage:image];
				[cell setNeedsLayout];
			});
		});
	}
	else
	{
		UIImageView * imageView = (id)[cell viewWithTag:1];
		imageView.image = [self.imageCache objectForKey:imageURL];
	}

	cell.layer.masksToBounds = NO;
	cell.layer.shadowOpacity = 0.4f;
	cell.layer.shadowRadius = 2.0f;
	cell.layer.shadowOffset = CGSizeMake(0, 1);
	cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	RBCollectionViewInfoFolderLayout * layout = (id)self.collectionView.collectionViewLayout;
	[layout toggleFolderViewForIndexPath:indexPath];
}

#pragma mark - RBCollectionViewInfoFolderLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForHeaderInSection:(NSInteger)section
{
	return CGSizeMake(self.view.bounds.size.width, 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout heightForFolderAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * title = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"title"];
	NSString * desc = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"description"];
	NSString * upc = self.data[self.dataKeys[indexPath.section]][@"results"][indexPath.row][@"upc"];
	
	CGSize constrainedSize = CGSizeMake(self.collectionView.frame.size.width - 20, CGFLOAT_MAX);

	return [ComicDataView heightOfViewWithTitle:title description:desc upc:upc constrainedToSize:constrainedSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForFooterInSection:(NSInteger)section
{
	return CGSizeMake(self.view.bounds.size.width, 25);
}


@end
