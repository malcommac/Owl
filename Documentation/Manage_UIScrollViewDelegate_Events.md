# 6 - APIs: Listen for `UIScrollViewDelegate` events

Both `TableDirector` and `CollectionDirector`/`FlowCollectionDirector` expose a property called `scrollEvents`.

From this property you can attach a list of events for the inner `UIScrollView` which are the same usually exposed via `UIScrollViewDelegate`.

### Available Events

| Event 	|
|-------------------------	|
| `didScroll` 	|
| `endScrollingAnimation` 	|
| `shouldScrollToTop` 	|
| `didScrollToTop` 	|
| `willBeginDragging` 	|
| `willEndDragging` 	|
| `endDragging` 	|
| `willBeginDecelerating` 	|
| `endDecelerating` 	|
| `viewForZooming` 	|
| `willBeginZooming` 	|
| `endZooming` 	|
| `didZoom` 	|
| `didChangeAdjustedContentInset` 	|

Each attachable event has the same parameters and output of the `UIScrollViewDelegate` counterpart.

Example:

```swift
director?.scrollEvents.didScroll = { scrollView in
	debugPrint("Scrolled to \(scrollView.contentOffset.y)")
}
```