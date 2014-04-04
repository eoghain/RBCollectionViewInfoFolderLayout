//
//  ViewController.m
//  RBCollectionViewInfoFolderLayout
//
//  Created by Rob Booth on 4/3/14.
//
//

#import "ViewController.h"
#import "RBCollectionViewInfoFolderLayout.h"

@interface ViewController ()

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
	layout.headerSize = CGSizeMake(self.view.bounds.size.width, 50);
	layout.footerSize = CGSizeMake(self.view.bounds.size.width, 25);

	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind withReuseIdentifier:@"header"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind withReuseIdentifier:@"footer"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind withReuseIdentifier:@"folder"];

	// TODO: Change this data structure to some comics and metadata
	// Setup Data - I know ugly data structure, but this is just a demo
	self.dataKeys = @[ @"Heroes", @"Villains"];
	self.data = @{ self.dataKeys[0] :	@[
						   @{ @"name" : @"Archangel", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/8/03/526165ed93180" },
						   @{ @"name" : @"Colossus", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/e0/51127cf4b996f" },
						   @{ @"name" : @"Cyclops", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/70/526547e2d90ad" },
						   @{ @"name" : @"Domino", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/f/60/526031dc10516" },
						   @{ @"name" : @"Emma Frost", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/9/80/51151ef7cf4c8" },
						   @{ @"name" : @"Gambit", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/a/40/52696aa8aee99" },
						   @{ @"name" : @"Ghost Rider (Johnny Blaze)", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/3/80/52696ba1353e7" },
						   @{ @"name" : @"Jubilee", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/c0/4e7a2148b6e59" },
						   @{ @"name": @"Iceman", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/1/d0/52696c836898c"},
						   ],
				   self.dataKeys[1] : @[
						   @{ @"name" : @"Doctor Doom", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/8/90/5273cac0ac417" },
						   @{ @"name": @"Sabretooth (Ultimate)", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/8/c0/4c0033dfc318e" },
						   @{ @"name": @"Magneto", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/3/b0/5261a7e53f827" },
						   @{ @"name": @"Mastermind", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/7/d0/4c003d43b02ab" },
						   @{ @"name": @"Black Cat (Ultimate)", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/5/80/4c00357da502e" },
						   @{ @"name" : @"Dracula", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/a/03/526955af18612" },
						   @{ @"name": @"Scalphunter", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/9/10/4ce5a473b81b3" },
						   ]
				   };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	// Keep headers full width
	RBCollectionViewInfoFolderLayout * layout = (id)self.collectionView.collectionViewLayout;
	layout.headerSize = CGSizeMake(self.view.bounds.size.width, 50);
	layout.footerSize = CGSizeMake(self.view.bounds.size.width, 25);
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.dataKeys count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.data[self.dataKeys[section]] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView * reuseView;

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

		reuseView.backgroundColor = (indexPath.section == 0) ? [UIColor whiteColor] : [UIColor blackColor];

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
		label.textColor = [UIColor blackColor];
		if (indexPath.section == 1)
		{
			label.textColor = [UIColor whiteColor];
		}
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];

		reuseView.backgroundColor = [UIColor colorWithRed:0xdc/255.0 green:0xdc/255.0 blue:0xdc/255.0 alpha:1];

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
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"folder" forIndexPath:indexPath];

		reuseView.backgroundColor = [UIColor lightGrayColor];

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

		label.text = self.data[self.dataKeys[indexPath.section]][indexPath.row][@"name"];
	}

	return reuseView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

	NSDictionary * portrait;
	portrait = self.data[self.dataKeys[indexPath.section]][indexPath.row];

	NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/standard_fantastic.jpg", portrait[@"path"]]];

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


@end
