Class {
	#name : #BlMemoryImageCache,
	#superclass : #BlImageCache,
	#instVars : [
		'cache',
		'cacheIndex'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #private }
BlMemoryImageCache >> cacheFileFor: aFileReference size: cacheSize [
	"Answer the file name used to cache aFileReference at cacheSize"

	^(aFileReference / cacheSize printString) pathString.

]

{ #category : #private }
BlMemoryImageCache >> cacheFileForUrl: znUrl size: cacheSize [

	^String streamContents: [ :stream |
		stream
			print: znUrl;
			<< '/';
			print: cacheSize ].

]

{ #category : #public }
BlMemoryImageCache >> cacheSize [ 
	"Answer the current cache size"

	^cache size
]

{ #category : #accessing }
BlMemoryImageCache >> entryAt: cacheKey [
	"Answer the entry at the supplied key, nil if none"

	^cache
		detect: [ :each | each key = cacheKey ]
		ifFound: [ :assoc | assoc value ]
		ifNone: [ nil ]
]

{ #category : #accessing }
BlMemoryImageCache >> entryAt: cacheKey put: aBlImageCacheEntry [
	"Set the entry at the supplied key"

	cacheIndex := cacheIndex >= cache size
		ifTrue: [ 1 ]
		ifFalse: [ cacheIndex + 1 ].
	^cache at: cacheIndex put: cacheKey -> aBlImageCacheEntry.

]

{ #category : #accessing }
BlMemoryImageCache >> fileAt: aFileReference size: minImageSize for: anObject [
	"Answer the Form for the specified file and requested size.
	If minImageSize isNil, answer the form from the original file.
	Otherwise answer the cached image which is larger than minImageSize."

	| fileReference cacheSize cacheKey cacheEntry form |

	fileReference := aFileReference asFileReference.
	cacheSize := self cacheSizeFor: minImageSize.
	(minImageSize isNil or: [ cacheSize isNil ]) ifTrue: [ 
		form := self formFor: fileReference.
		^self set: anObject form: form size: form extent max isOriginal: true ].

	cacheKey := self cacheFileFor: fileReference size: cacheSize.
	(self entryAt: cacheKey) ifNotNil: [ :entry | 
		hits := hits + 1.
		^entry ].

	form := self formFor: fileReference.
	misses := misses + 1.
	cacheSize >= form extent max ifTrue: 
		[ ^self set: anObject form: form size: form extent max isOriginal: true ].
	form := form scaledToSize: cacheSize@cacheSize.
	cacheEntry := self answerForm: form size: cacheSize isOriginal: false.
	self entryAt: cacheKey put: cacheEntry.
	^anObject entry: cacheEntry.

]

{ #category : #accessing }
BlMemoryImageCache >> flush [ 
	"Empty the receiver cache"

	"The cache is initialised while setting the max cache size"
	self maxCacheSize: maxCacheSize
]

{ #category : #initialization }
BlMemoryImageCache >> initialize [ 

	super initialize.
	self maxCacheSize: 5.
]

{ #category : #configuration }
BlMemoryImageCache >> maxCacheSize: anInteger [

	super maxCacheSize: anInteger.
	cache := Array new: maxCacheSize withAll: nil -> nil.
	cacheIndex := 0.
]

{ #category : #'system startup' }
BlMemoryImageCache >> shutDown: quitting [
	"Flush the cache on session shutdown so random images aren't bloating the image and left on disk"
	
	self flush
]
