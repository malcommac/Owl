[< Back to Index](../README.md)

# 5 - APIs: Manage `UICollectionView`

- 5.1 - `CollectionDirector` & `FlowCollectionDirector`
	- `CollectionDirector` Properties
	- `FlowCollectionDirector` Additional Properties
	- Methods: Register Adapters (Cell/Header/Footer)
	- Methods: Manage Contents
- 5.2 - Manage Sections: `CollectionSection`
	- Properties
	- Methods: Manage Contents
- 5.3 - Manage Cells: `CollectionAdapter`
	- Introduction
	- Available Events
- 5.4 - Manage Header/Footer: `CollectionHeaderFooterAdapter `
	- Introduction
	- Available Events

## `CollectionDirector` & `FlowCollectionDirector`

`CollectionDirector` is the class used to manage an instance of a `UICollectionView`.
If you are about to use a Flow-Layout based collection view you should use `FlowCollectionDirector` instead because it offers more specific properties and events.

```swift
	// For Flow-Layout based collection views
	director = FlowCollectionDirector(collection: myCollectionView)
	
	// Other generic collection views
	director = CollectionDirector(collection: myCollectionView)
```

You should keep it alive (usually you will create a property in your view controller).

### `CollectionDirector` Properties

| Property 	| Description 	|
|---------------------------------	|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `collection` (`UICollectionView`) 	| Managed collection view instance. 	|
| `sections` (`[CollectionSection]`) 	| List of sections of the collection; use methods below to alter this list. 	|
| `firstSection` (`CollectionSection `) 	| Return the first section of the collection. 	|
| `lastSection` (`CollectionSection `) 	| Return the last section of the collection. 	|
| `scrollEvents` (`CollectionSection `) 	| Entry point to listen for base `UIScrollViewDelegate` events. See the `Listen for UIScrollViewDelegate` events below. 	|

### `FlowCollectionDirector` Additional Properties

| Property 	| Description 	|
|---------------------------------	|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `itemSize` (`ItemSize`) 	| Define the size of the item. `explicit` to use a fixed item size (suggested if you don't plan to have dynamic sized rows), `auto(estimated:)` to use autolayout for cell-sizing, `default` to set `automaticDimension`. 	|
| `sectionsInsets` (`UIEdgeInsets`) 	| Margins to apply to content. This is a global value, you can customize a per-section behaviour by implementing `sectionInsets` property into a section. Initially is set to `.zero`. 	|
| `minimumInteritemSpacing` (`CGFloat`) 	| Minimum spacing (in points) to use between items in the same row or column. This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section. Initially is set to `CGFloat.leastNormalMagnitude`. 	|
| `minimumLineSpacing` (`CGFloat`) 	| The minimum spacing (in points) to use between rows or columns. This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section. Initially is set to `0`. 	|
| `stickyHeaders` (`Bool`) 	| When this property is true, section header views scroll with content until they reach the top of the screen, at which point they are pinned to the upper bounds of the collection view. Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen. The default value of this property is `false`. 	|
| `stickyFooters` (`Bool`) 	| When this property is true, section footer views scroll with content until they reach the bottom of the screen, at which point they are pinned to the lower bounds of the collection view. Each new footer view that scrolls to the bottom of the screen pushes the previously pinned footer view offscreen. The default value of this property is `false`. 	|
| `sectionInsetReference` (`SectionInsetReference`) 	| Set the section reference starting point.	|

### Methods: Register Adapters (Cell/Header/Footer)

| Method 	| Description 	|
|----------------------------------	|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `registerCellAdapters()` 	| Register a sequence of adapter for the collection. If an adapter is already registered request will be ignored automatically. 	|
| `registerCellAdapter()` 	| Register a new adapter for the collection. An adapter represent the entity composed by the pair used by the directory to manage their representation inside the collection itself. If adapter is already registered it will be ignored automatically. 	|
| `registerHeaderFooterAdapters()` 	| Register a set of adapters to render header/footer's custom views. 	|
| `registerHeaderFooterAdapter()` 	| Register a new adapter to render custom header/footer's view. 	|

### Methods: Manage Content

| Method 	| Description 	|
|-------------------------------	|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `set(sections:)` 	| Replace all the sections of the collection with another set. 	|
| `add(section:at:)` 	| Append a new section at the specified index of the collection. If `index` is `nil` or not specified section will be happend, at the bottom of the collection. 	|
| `add(sections:at:)` 	| Add multiple section starting at specified index., If `index` is `nil` or omitted all sections will be added at the end of tha collection. 	|
| `section(at:)` 	| Get the section at specified index. If `index` is invalid `nil` is returned. 	|
| `elementAt()` 	| Return element at given index path. If index is invalid `nil` is returned. 	|
| `remove(section:)` 	| Remove section at specified index. If `index` is invalid no action is made and function return `nil`. 	|
| `remove(sectionsAt:)` 	| Remove sections at specified indexes. Sections are removed in reverse order to keep consistency; any invalid index is ignored. 	|
| `removeAll(keepingCapacity:)` 	| Remove all sections from the collection. Pass `true` to keep the existing capacity, of the array after removing its elements. The default value is `false`. 	|
| `move(swappingAt:with:)` 	| Swap source section at specified index with another section. If indexes are not valid no operation is made. 	|
| `move(from:to:)` 	| Move section at specified index to a destination index. If indexes are invalids no operation is made. 	|
| `add(elements:inSection:)` 	| Append items at the bottom of section at specified index. If section index is not specified a new section is created and append, at the end of the collection with all items. 	|

## Manage Sections: `CollectionSection`

`CollectionSection` represent a single section in a UICollectionView.
A director can have 0...n `CollectionSection ` instance; each section is identified by an UUID which is generated automatically or assigned at init.
The UUID is used when comparing changes between data altering sessions.

A `CollectionSection` may have:

- `elements` a list of the elements inside the section. Can be an heterogeneous dataset; the only requirement is you have registered an adapter for each pair of `<Model,Cell>`.
- `headerTitle` if set it shows a simple string-based header.
- `footerTitle` if set it shows a simple string-based footer.
- `headerView` if set it shows a custom view header. View must be registered by using director's `registerHeaderFooterAdapters()` function and passing an instance of `CollectionHeaderFooterAdapter<YourCustomView>`.
- `footerTitle` if set it shows a custom view footer. See `headerView` for more info.

### Properties

| Property 	| Description 	|
|---------------------------------------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `identifier` (`String`) 	| Unique identify a section. This value is assigned automatically if omitted at the init and it's used by the diff algorithm to compare changes between operations set with models. 	|
| `headerTitle` (`String`) 	| If not `nil` this value represent a simple string-based header for the section. 	|
| `footerTitle` (`String`) 	| If not `nil` this value represent a simple string-based footer for the section. 	|
| `headerView` (`CollectionHeaderFooterAdapterProtocol`) 	| When set it assign a custom view based header to the section (it overrides `headerTitle`) 	|
| `footerView` (`CollectionHeaderFooterAdapterProtocol`) 	| When set it assign a custom view based footer to the section (it overrides `footerTitle`) 	|
| `isCollapsed` (`Bool`) 	| If true the section is collapsed and no elements/rows are visible (elements are hidden but kept alive) 	|
| `elements` (`[ElementRepresentable]`) 	| Array of elements inside the section. Use methods below to manipulate them. 	|

For Flow Layout collection view these properties are also available:

| Property 	| Description 	|
|---------------------------------------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `sectionInsets` (`UIEdgeInsets?`) 	| Implement this method when you want to provide margins for sections in the flow layout. If you do not implement this method, the margins are obtained from the properties of the flow layout object.
 	|
| `minimumInterItemSpacing` (`CGFloat?`) 	| The minimum spacing (in points) to use between items in the same row or column. If you do not implement this method, value is obtained from the properties of the flow layout object.
 	|
| `minimumLineSpacing ` (`CGFloat?`) 	| The minimum spacing (in points) to use between rows or columns. If you do not implement this method, value is obtained from the properties of the flow layout object.
 	

### Methods: Manage Content

| Methods 	| Description 	|
|-------------------------------	|------------------------------------------------------------------------------	|
| `set(elements:)` 	| Replace the current content of the elements into the section with a new set. 	|
| `set(element:at:)` 	| Replace a model instance at specified index with a new object. 	|
| `add(element:at:)` 	| Add a new element at given index. 	|
| `add(elements:at:)` 	| Add elements starting at given index of the array. 	|
| `remove(at:)` 	| Remove element at given index. 	|
| `remove(atIndexes:)` 	| Remove elements at given indexes set. 	|
| `removeAll(keepingCapacity:)` 	| Remove all elements into the section. 	|
| `move(swappingAt:with:)` 	| Swap element at given index to another destination index. 	|
| `move(from:to:)` 	| Remove element at given index and insert at destination index. 	|

## Manage Cells: `CollectionAdapter`

### Introduction

A cell adapter allows you to register a pair of `<Model,Cell>` objects which is used to represent a `Model` (any object conforms to `ElementRepresentable` protocol) with a specified `Cell` subclass (`UICollectionViewCell`).

Once you have registered a new adapter you can add instances of `Models` into your director's sections and FlowKit take care of allocating resources and render the content.

Each `CollectionAdapter ` has an `events` property where you can configure both the appearance and behaviour of the cell which represent the content.

In the following example we want to customize both the tap and dequeue of a `EmojiCell ` cell which represent a `String` model (which is just an emoji)

```swift
let emojiAdapter = CollectionCellAdapter<String, EmojiCell> { adapter in
	// configure dequeue
	adapter.events.dequeue = { ctx in
		ctx.cell?.emoji = ctx.element
	}
	
	// configure item size
	adapter.events.itemSize = { ctx in
		return CGSize(width: 50, height: 50)
	}
}
director?.registerAdapter(emojiAdapter)
```

### Available Events

All events will receive at least one parameter called context, which is an instance of `Event` class with the following properties:

- `indexPath` (`IndexPath`): Source index path (if available).
- `element` (type-safe instance of the registered adapter's model): the instance of the model involved into the action (if available).
- `cell` (type-safe instance of the registered adapter's cell): the instance of the involved cell (if available).

You can use these properties to manage the inner behaviour of the subscribed event.

This is the list of all events you can subscribe; they are equivalent to the classic `UICollectionViewDatasource`/`UICollectionViewDelegate`/`UICollectionViewFlowLayoutDelegate` delegate events, so you can refeer to them for a detailed documentation:

| Event 	|
|-------------------------	|
| `dequeue` 	|
| `shouldSelect` 	|
| `shouldDeselect` 	|
| `didSelect` 	|
| `didDeselect` 	|
| `didHighlight` 	|
| `didUnhighlight` 	|
| `shouldHighlight` 	|
| `willDisplay` 	|
| `endDisplay` 	|
| `shouldShowEditMenu` 	|
| `canPerformEditAction` 	|
| `performEditAction` 	|
| `canFocus` 	|
| `itemSize` 	|
| `prefetch` 	|
| `cancelPrefetch` 	|
| `shouldSpringLoad` 	|

## Manage Header/Footer: `CollectionHeaderFooterAdapter`

### Introduction

`CollectionHeaderFooterAdapter ` is used to manage custom view-based header/footer for a `CollectionSection`.
These view must be subclass of `UICollectionReusableView`.

This is an example:

```swift
// STEP 1: Create an adapter for your custom view class
// custom view (here EmojiHeaderView) must be a subclass of UICollectionReusableView
let myHeaderAdapter = CollectionHeaderFooterAdapter<EmojiHeaderView> { cfg in
	cfg.events.dequeue = { ctx in
		ctx.view?.titleLabel.text = ctx.section?.identifier ?? "-"
	}
}

// STEP 2: Register adapter to director
director?.registerHeaderFooterAdapter(myHeaderAdapter)

// ...
// STEP 3: Use it for your section(s)
let section = CollectionSection(id: "Section \(idx)", elements: elements, header: myHeaderAdapter)
```

### Available Events

Also `CollectionHeaderFooterAdapter` has an `events` property where you can subscribe for events coming to your custom view instance of header/footer.

Each subscribed events is a callback which will receive an `CollectionHeaderFooterAdapter.Event` instance object which is an object with all relevant informations of the event:

- `isHeader` (`Bool`): `true` if events regards the view instance as header, `false` if it's a footer.
- `section` (`Int`): Header/footer section index.
- `view` (type-safe instance of the registered h/f adapter's view): instance of the custom header/footer view (if available).

The list of events is the same of a classic `UICollectionView` so please refer to the documentation in order to known more.

| Event 	|
|-------------------------	|
| `dequeue` 	|
| `referenceSize` 	|
| `didDisplay` 	|
| `endDisplay` 	|
| `willDisplay` 	|
