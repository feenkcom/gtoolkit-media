"
BlWorkerImageCache provides the same capabilities as ${class:name=BlLocalImageCache}$ but delegates the work of populating the cache to slave pharo processes. 


!!Public API and Key Messages

The public API is the same as for ${class:name=BlLocalImageCache}$.

"
Class {
	#name : #BlWorkerImageCache,
	#superclass : #BlLocalImageCache,
	#category : #'GToolkit-Images-Cache'
}

{ #category : #'accessing - cache' }
BlWorkerImageCache >> fileAt: aFileReference size: minImageSize for: anObject [
	"Set the #entry: in anObject for the specified file and requested size.
	If minImageSize isNil, set the form from the original file.
	Otherwise set the cached image which is larger than minImageSize."

	| fileReference cacheSize cacheFile form |

	fileReference := aFileReference asFileReference.
	cacheSize := self cacheSizeFor: minImageSize.
	(minImageSize isNil or: [ cacheSize isNil ]) ifTrue: [ 
		form := self formFor: fileReference.
		^self set: anObject form: form size: form extent max isOriginal: true ].
	cacheFile := self cacheFileFor: fileReference size: cacheSize.
	cacheFile exists ifTrue: [ 
		hits := hits + 1.
		^self set: anObject form: (self formFor: cacheFile) size: cacheSize isOriginal: false ].

	misses := misses + 1.
	"Ask the worker to ensure that cache entry exists, then load it"
	cacheFile := (BlTlpWorkerPool current workerEvaluate: [ BlLocalImageCache current ensureCacheFileForFile: aFileReference size: minImageSize ]).
	^cacheFile
		ifNotNil: [ self set: anObject form: (self formFor: cacheFile) size: cacheSize isOriginal: false ]
		ifNil: [ self error: 'Cache inconsistency' ]
]