#InfoFolderLayout

A UICollectionViewLayout that uses a supplimental view to display a folder below a cell that looks like the screen was split.  Mimics the pre iOS7 springboard groups visualization.  Wrote this because all of the other "folder" controls like this use a screen shot to do the splitting, but I wanted my collection view to still be functional even with the folder open.

## Screenshots
Only got the one for now, but run the demo to check out how the animations look and work.

<p align="center">
<img src="https://raw.githubusercontent.com/eoghain/RBCollectionViewInfoFolderLayout/master/screenshots/portrait.png" alt="Portrait" title="Screenshot 1" height="600">
</p>

## Usage

1. Copy RBCollectionViewInfoFolderLayout .h/.m into your project
2. Set the layout on your collectionView to Custom, and set it's name to RBCollectionViewInfoFolderLayout
3. Grab the layout in viewDidLoad and setup your collectionView (Note: currently you have to register a RBCollectionViewInfoFolderDimpleKind)
4. Implement the delegate methods

``` objective-c
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout heightForFolderAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForFooterInSection:(NSInteger)section;
```

### Examples
Setup layout
``` objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];

	RBCollectionViewInfoFolderLayout * layout = (id)self.collectionView.collectionViewLayout;
	layout.cellSize = CGSizeMake(216, 325);
	layout.interItemSpacingY = 10;
	layout.stickyHeaders = YES;

	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderHeaderKind withReuseIdentifier:@"header"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFooterKind withReuseIdentifier:@"footer"];
	[self.collectionView registerClass:[ComicDataView class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderFolderKind withReuseIdentifier:@"folder"];
	[self.collectionView registerClass:[RBCollectionViewInfoFolderDimple class] forSupplementaryViewOfKind:RBCollectionViewInfoFolderDimpleKind withReuseIdentifier:@"dimple"];
}
```
Handle various suplementary view request
``` objective-c
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView * reuseView;

	if (kind == RBCollectionViewInfoFolderHeaderKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
		// Nothing new here, you've done it before
	}

	if (kind == RBCollectionViewInfoFolderFooterKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
		// Nothing new here, you've done it before
	}

	// Example from our demo showing the use of a custom UICollectionReusableView
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

	// Example of how to color the dimple to match your folder
	if (kind == RBCollectionViewInfoFolderDimpleKind)
	{
		RBCollectionViewInfoFolderDimple * dimple = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"dimple" forIndexPath:indexPath];
		dimple.color = [UIColor colorWithRed:0x88/255.0 green:0xc2/255.0 blue:0xc4/255.0 alpha:1.0];
		reuseView = dimple;
	}

	return reuseView;
}
```

####TODO

- [X] Imlement decoration view that places a caret over opened item linking it to the folder
- [X] Animate dimple decoration
- [ ] Make header/footer/dimple optional
- [X] Figure out why position of the folder animates open, but the view just pops in
- [X] Implement sticky headers
- [ ] Refactor deltaX calculation into prepareLayout so it isn't re-done for every item 
- [X] Allow for per item folder heights.
- [X] Implement delegate methods to allow per-section headers/footers
- [ ] Add SectionInset property/delegate
