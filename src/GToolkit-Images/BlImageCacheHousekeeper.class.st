Class {
	#name : #BlImageCacheHousekeeper,
	#superclass : #Object,
	#instVars : [
		'cache',
		'currentSize',
		'entryCount',
		'emergencySize',
		'processing',
		'targetSize'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #'instance creation' }
BlImageCacheHousekeeper class >> for: aBlImageCache [

	^self new initializeWith: aBlImageCache
]

{ #category : #accessing }
BlImageCacheHousekeeper >> add: aFileReference [
	"aFileReference has been added to the cache, update the internal size counter"

	currentSize := currentSize + aFileReference size.
	BlImageCacheSignal emitEvent: #addedFile value: aFileReference currentSize: currentSize.
	"If the cache has grown larger than the emergency size, prune immediately
	(on the assumption that the low priority process isn't getting a chance to run"
	currentSize >= emergencySize ifTrue:
		[ self pruneCache ]
	ifFalse: [ currentSize > self maxCacheSize ifTrue:
		[ self schedulePruneCache ] ]
]

{ #category : #accessing }
BlImageCacheHousekeeper >> cacheRoot [ 

	^cache cacheRoot
]

{ #category : #accessing }
BlImageCacheHousekeeper >> currentSize [

	^currentSize
]

{ #category : #initialization }
BlImageCacheHousekeeper >> initialize [ 

	super initialize.
	processing := false.
	currentSize := 0.
]

{ #category : #initialization }
BlImageCacheHousekeeper >> initializeWith: aBlImageCache [

	cache := aBlImageCache.
	targetSize := (cache maxCacheSize * 0.80) rounded.
	emergencySize := cache maxCacheSize * 2.

]

{ #category : #accessing }
BlImageCacheHousekeeper >> maxCacheSize [ 

	^cache maxCacheSize
]

{ #category : #private }
BlImageCacheHousekeeper >> pruneCache [
	"Walk over the receiver's cache and remove enough old items to reduce the cache size to targetSize"

	BlImageCacheSignal emitEvent: #pruneStarting value: nil currentSize: currentSize.
	(BlCachePruningVisitor on: self) delete.
	self updateCurrentSize.
	BlImageCacheSignal emitEvent: #pruneCompleted value: nil currentSize: currentSize.

]

{ #category : #private }
BlImageCacheHousekeeper >> schedulePruneCache [
	"Prune the receiver's cache in the housekeeping process"

	BlHousekeepingWorkerPool schedule: [ self pruneCache ] maxPoolSize: 1
]

{ #category : #private }
BlImageCacheHousekeeper >> scheduleUpdateCurrentSize [
	"Update the size of the receiver's cache in the housekeeping process"

	cache taskitRunner schedule: [ self updateCurrentSize ] maxPoolSize: 1
]

{ #category : #private }
BlImageCacheHousekeeper >> targetSize [

	^targetSize
]

{ #category : #private }
BlImageCacheHousekeeper >> updateCurrentSize [
	"Update the current size of the receiver's cache"

	| usageVisitor |

	usageVisitor := BlDiskUsageVisitor on: cache cacheRoot.
	entryCount := usageVisitor entryCount.
	^currentSize := usageVisitor total.
]
