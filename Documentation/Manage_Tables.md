[< Back to Index](../README.md)

<a name="index"/>

# 4 - APIs: Manage `UITableView`

- [4.1 - `TableDirector`](#4.1)
	- [Properties](#4.1.1)
	- [Methods: Register Adapters (Cell/Header/Footer)](#4.1.2)
	- [Methods: Manage Contents](#4.1.3)
- [4.2 - Manage Sections: `TableSection`](#4.2)
	- [Properties](#4.2.1)
	- [Methods: Manage Contents](#4.2.2)
- [4.3 - Manage Cells: `TableAdapter`](#4.3)
	- [Introduction](#4.3.1)
	- [Available Events](#4.3.2)
- [4.4 - Manage Header/Footer: `TableHeaderFooterAdapter`](#4.4)
	- [Introduction](#4.4.1)
	-[ Available Events](#4.4.2)
	
<a name="4.1"/>

## `TableDirector`

`TableDirector` is the class used to manage an instance of an `UITableView`. You need to allocate an instance of this object before using your table.
The only init allowed require a valid instance of `UITableView`.

```swift
	director = TableDirector(table: myTableView)
```

You should keep it alive (usually you will create a property in your view controller).

<a name="4.1.1"/>

### Properties

| Property 	| Description 	|
|---------------------------------	|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `table` (`UITableView`) 	| Managed table view instance. 	|
| `sections` (`[TableSection]`) 	| List of sections of the table; use methods below to alter this list. 	|
| `firstSection` (`TableSection`) 	| Return the first section of the table. 	|
| `lastSection` (`TableSection`) 	| Return the last section of the table. 	|
| `rowHeight` (`RowHeight`) 	| Height of the row. `explicit` to use a fixed row height (suggested if you don't plan to have dynamic sized rows), `auto(estimated:)` to use autolayout for cell-sizing, `default` to set `automaticDimension`. 	|

<a name="4.1.2"/>

### Methods: Register Adapters (Cell/Header/Footer)

| Method 	| Description 	|
|----------------------------------	|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `registerCellAdapters()` 	| Register a sequence of adapter for the table. If an adapter is already registered request will be ignored automatically. 	|
| `registerCellAdapter()` 	| Register a new adapter for the table. An adapter represent the entity composed by the pair used by the directory to manage their representation inside the table itself. If adapter is already registered it will be ignored automatically. 	|
| `registerHeaderFooterAdapters()` 	| Register a set of adapters to render header/footer's custom views. 	|
| `registerHeaderFooterAdapter()` 	| Register a new adapter to render custom header/footer's view. 	|

<a name="4.1.3"/>

### Methods: Manage Content

| Method 	| Description 	|
|-------------------------------	|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `set(sections:)` 	| Replace all the sections of the table with another set. 	|
| `add(section:at:)` 	| Append a new section at the specified index of the table. If `index` is `nil` or not specified section will be happend, at the bottom of the table. 	|
| `add(sections:at:)` 	| Add multiple section starting at specified index., If `index` is `nil` or omitted all sections will be added at the end of tha table. 	|
| `section(at:)` 	| Get the section at specified index. If `index` is invalid `nil` is returned. 	|
| `elementAt()` 	| Return element at given index path. If index is invalid `nil` is returned. 	|
| `remove(section:)` 	| Remove section at specified index. If `index` is invalid no action is made and function return `nil`. 	|
| `remove(sectionsAt:)` 	| Remove sections at specified indexes. Sections are removed in reverse order to keep consistency; any invalid index is ignored. 	|
| `removeAll(keepingCapacity:)` 	| Remove all sections from the table. Pass `true` to keep the existing capacity, of the array after removing its elements. The default value is `false`. 	|
| `move(swappingAt:with:)` 	| Swap source section at specified index with another section. If indexes are not valid no operation is made. 	|
| `move(from:to:)` 	| Move section at specified index to a destination index. If indexes are invalids no operation is made. 	|
| `add(elements:inSection:)` 	| Append items at the bottom of section at specified index. If section index is not specified a new section is created and append, at the end of the table with all items. 	|

<a name="4.2"/>

## Manage Sections: TableSection

TableSection represent a single section in a UITableView.
A director can have 0...n `TableSection` instance; each section is identified by an UUID which is generated automatically or assigned at init.
The UUID is used when comparing changes between data altering sessions.

A `TableSection` may have:

- `elements` a list of the elements inside the section. Can be an heterogeneous dataset; the only requirement is you have registered an adapter for each pair of `<Model,Cell>`.
- `headerTitle` if set it shows a simple string-based header.
- `footerTitle` if set it shows a simple string-based footer.
- `headerView` if set it shows a custom view header. View must be registered by using director's `registerHeaderFooterAdapters()` function and passing an instance of `TableHeaderFooterAdapter<YourCustomView>`.
- `footerTitle` if set it shows a custom view footer. See `headerView` for more info.

<a name="4.2.1"/>

### Properties

| Property 	| Description 	|
|---------------------------------------------------	|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| `identifier` (`String`) 	| Unique identify a section. This value is assigned automatically if omitted at the init and it's used by the diff algorithm to compare changes between operations set with models. 	|
| `headerTitle` (`String`) 	| If not `nil` this value represent a simple string-based header for the section. 	|
| `footerTitle` (`String`) 	| If not `nil` this value represent a simple string-based footer for the section. 	|
| `headerView` (`TableHeaderFooterAdapterProtocol`) 	| When set it assign a custom view based header to the section (it overrides `headerTitle`) 	|
| `footerView` (`TableHeaderFooterAdapterProtocol`) 	| When set it assign a custom view based footer to the section (it overrides `footerTitle`) 	|
| `isCollapsed` (`Bool`) 	| If true the section is collapsed and no elements/rows are visible (elements are hidden but kept alive) 	|
| `indexTitle` (`String`) 	| Title of the section in right single char column of the table. If value is set it will displayed into the table's section indexes. 	|
| `elements` (`[ElementRepresentable]`) 	| Array of elements inside the section. Use methods below to manipulate them. 	|

<a name="4.2.2"/>

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

<a name="4.3"/>

## Manage Cells: `TableAdapter`

<a name="4.3.1"/>

### Introduction

A table adapter allows you to register a pair of `<Model,Cell>` objects which is used to represent a `Model` (any object conforms to `ElementRepresentable` protocol) with a specified `Cell` subclass (`UITableViewCell`).

Once you have registered a new adapter you can add instances of `Models` into your director's sections and FlowKit take care of allocating resources and render the content.

Each `TableAdapter` has an `events` property where you can configure both the appearance and behaviour of the cell which represent the content.

In the following example we want to customize both the tap and dequeue of a `ContactCell` cell which represent a `Contact` model.

```swift
let contactAdapter = TableCellAdapter<Contact,ContactCell> { dr in
	
	// attach to dequeue event to make some stuff with the ui
	dr.events.dequeue = { ctx in // event as Event
		ctx.cell?.item = ctx.element
	}
	
	// attach did select event
	dr.events.didSelect = { ctx in
		debugPrint("Tapped on people \(ctx.element) at index: \(ctx.indexPath)")
	}
}

director?.registerAdapter(contactAdapter)
```

<a name="4.3.2"/>

### Available Events

All events will receive at least one parameter called context, which is an instance of `TableCellAdapter.Event` class with the following properties:

- `indexPath` (`IndexPath`): Source index path (if available).
- `element` (type-safe instance of the registered adapter's model): the instance of the model involved into the action (if available).
- `cell` (type-safe instance of the registered adapter's cell): the instance of the involved cell (if available).

You can use these properties to manage the inner behaviour of the subscribed event.

This is the list of all events you can subscribe; they are equivalent to the classic `UITableViewDataSource`/`UITableViewDelegate` delegate events, so you can refeer to them for a detailed documentation:

| Event 	|
|-------------------------	|
| `dequeue` 	|
| `willDisplay` 	|
| `rowHeight` 	|
| `rowHeightEstimated` 	|
| `canEditRow` 	|
| `commitEdit` 	|
| `editActions` 	|
| `canMoveRow` 	|
| `moveRow` 	|
| `indentLevel` 	|
| `prefetch` 	|
| `cancelPrefetch` 	|
| `shouldSpringLoad` 	|
| `tapOnAccessory` 	|
| `willSelect` 	|
| `didSelect` 	|
| `willDeselect` 	|
| `didDeselect` 	|
| `willBeginEdit` 	|
| `didEndEdit` 	|
| `editStyle` 	|
| `deleteConfirmTitle` 	|
| `editShouldIndent` 	|
| `moveAdjustDestination` 	|
| `endDisplay` 	|
| `shouldShowMenu` 	|
| `canPerformMenuAction` 	|
| `performMenuAction` 	|
| `shouldHighlight` 	|
| `didHighlight` 	|
| `didUnhighlight` 	|
| `canFocus` 	|
| `leadingSwipeActions` 	|
| `trailingSwipeActions` 	|

<a name="4.4"/>

## Manage Header/Footer: `TableHeaderFooterAdapter`

<a name="4.4.1"/>

### Introduction

`TableHeaderFooterAdapter` is used to manage custom view-based header/footer for a `TableSection`.

This is an example:

```swift
// STEP 1: Create an adapter for your custom view class
// custom view (here EmojiHeaderView) must be a subclass of UITableViewHeaderFooterView class
let myHeaderAdapter = TableHeaderFooterAdapter<EmojiHeaderView> { cfg in
	cfg.events.dequeue = { ctx in // event as HeaderFooterEvent
		ctx.view?.titleLabel.text = ctx.section?.identifier ?? "-"
	}
}
// STEP 2: Register adapter to director
director?.registerHeaderFooterAdapter(headerAdapter)

// ...
// STEP 3: Use it for your section(s)
let section = TableSection(id: "Section \(idx)", elements: elements, header: myHeaderAdapter)
```

<a name="4.4.2"/>

### Available Events

Also `TableHeaderFooterAdapter` has an `events` property where you can subscribe for events coming to your custom view instance of header/footer.

Each subscribed events is a callback which will receive an `HeaderFooterEvent` instance object which is an object with all relevant informations of the event:

- `isHeader` (`Bool`): `true` if events regards the view instance as header, `false` if it's a footer.
- `section` (`Int`): Header/footer section index.
- `view` (type-safe instance of the registered h/f adapter's view): instance of the custom header/footer view (if available).

The list of events is the same of a classic `UITableView` so please refer to the documentation in order to known more.

| Event 	|
|-------------------------	|
| `dequeue` 	|
| `headerHeight` 	|
| `footerHeight` 	|
| `estHeaderHeight` 	|
| `estFooterHeight` 	|
| `endDisplay` 	|
| `willDisplay` 	|


- [< Back to Index](../README.md)
- [< Back to Top](#index)
