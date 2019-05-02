Class {
	#name : #BlCachePruningVisitor,
	#superclass : #FileSystemVisitor,
	#instVars : [
		'housekeeper',
		'oldest',
		'oldestSize',
		'targetSize',
		'reductionSize',
		'count',
		'newestOldestTime'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #'instance creation' }
BlCachePruningVisitor class >> on: aBlImageCacheHousekeeper [

	^self new 
		on: aBlImageCacheHousekeeper;
		yourself
]

{ #category : #actions }
BlCachePruningVisitor >> delete [ 

	| entries |

	entries := oldest collect: [ :each | each reference parent ] as: Set.
	entries do: [ :each | each ensureDeleteAll ].
	BlImageCacheSignal emitEvent: #pruneDeleted value: entries size currentSize: housekeeper currentSize

]

{ #category : #initialization }
BlCachePruningVisitor >> initialize [ 

	super initialize.
	oldest := SortedCollection sortBlock: #modificationTime ascending.
	oldestSize := 0.
]

{ #category : #'instance creation' }
BlCachePruningVisitor >> on: aBlImageCacheHousekeeper [

	housekeeper := aBlImageCacheHousekeeper.
	reductionSize := housekeeper currentSize - housekeeper targetSize.
	count := 0.
	newestOldestTime := DateAndTime now.
	(PreorderGuide for: self) show: housekeeper cacheRoot.
	BlImageCacheSignal emitEvent: #pruneCount value: count currentSize: housekeeper currentSize

]

{ #category : #visiting }
BlCachePruningVisitor >> visitFile: anEntry [

	count := count + 1.
	(anEntry modificationTime < newestOldestTime or: [ oldestSize < reductionSize ]) ifTrue: [ 
		oldest add: anEntry.
		oldestSize := oldestSize + anEntry size ].
	[ oldestSize > reductionSize ] whileTrue: 
		[ oldestSize := oldestSize - (oldest removeLast size) ].
	newestOldestTime := oldest last modificationTime
]
