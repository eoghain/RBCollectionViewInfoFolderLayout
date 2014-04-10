#InfoFolderLayout

A UICollectionViewLayout that uses a supplimental view to display a folder below a cell that looks like the screen was split.  Mimics the pre iOS7 springboard groups visualization.  Wrote this because all of the other "folder" controls like this use a screen shot to do the splitting, but I wanted my collection view to still be functional even with the folder open.

## Usage

1. Copy RBCollectionViewInfoFolderLayout .h/.m into your project
2. Set the layout on your collectionView to Custom, and set it's name to RBCollectionViewInfoFolderLayout
3. Implement the following delegate methods

``` objective-c
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout heightForFolderAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewInfoFolderLayout *)collectionViewLayout sizeForFooterInSection:(NSInteger)section;
```
####TODO

- [X] Imlement decoration view that places a caret over opened item linking it to the folder
- [X] Animate caret decoration
- [ ] Make decoration optional
- [C] Figure out why position of the folder animates open, but the view just pops in
- [X] Implement sticky headers
- [ ] Refactor deltaX calculation into prepareLayout so it isn't re-done for every item 
- [X] Allow for per item folder heights.
- [X] Implement delegate methods to allow per-section headers/footers
