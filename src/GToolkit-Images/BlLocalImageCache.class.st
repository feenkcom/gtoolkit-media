"
BlLocalImageCache provides a cache of file system and network images at specified sizes.

- Cache entries are created lazily, i.e. only when a cache entry of the specified size is requested.
- If the original image size is smaller than the cache size, the original will be returned.


Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	cacheRoot:		<Object>
	fileRoot:		<Object>
	imageSizes:		<Object>
	maxCacheSize:		<Object>
	networkRoot:		<Object>


!!!Implementation Points

To allow lookup in the file system cache to be quick either an index has to be held in memory or the cache entries found quickly.

The current assumption is that the memory cost of an in-memory index is too high.

Scanning a directory looking for files is slow - Pharo always walks over all the files in the directory and matches the file name.  Determining whether a given file exists is fast, a single plugin primitive call.

So we want the cache structure to allow lookup to be determined on the basis of a known file / directory existing or not.  The chosen structure is:

	fileRoot / <path to image> / <image file name> / <cache entry name>.jpg

The directory containing the cache entries can then easily be tested for existence.
"
Class {
	#name : #BlLocalImageCache,
	#superclass : #BlImageCache,
	#instVars : [
		'cacheRoot',
		'fileRoot',
		'networkRoot',
		'maxCacheSize',
		'imageSizes',
		'taskitRunner',
		'housekeeper',
		'hits',
		'misses'
	],
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #accessing }
BlLocalImageCache class >> current [ 

	^Current ifNil: [ 	Current := self new setDefaultLocation  ]
]

{ #category : #managing }
BlLocalImageCache class >> stopCurrent [
	<script>
	"Flush the default image cache and clear the pointer.
	Note that this currently leaves 3 directories behind"

	Current ifNil: [ ^self ].
	Current flush.
	Current := nil.
]

{ #category : #private }
BlLocalImageCache >> cacheFileFor: aFileReference size: cacheSize [
	"Answer the file name used to cache aFileReference at cacheSize"

	| cacheFile |

	cacheFile := fileRoot.
	aFileReference path segments do: 
		[ :each | cacheFile := cacheFile / each ].
	cacheFile := cacheFile / (cacheSize printString, '.jpg').
	^cacheFile
]

{ #category : #private }
BlLocalImageCache >> cacheFileForUrl: znUrl size: cacheSize [

	| fileReference hash |

	hash := (SHA256 new hashStream: znUrl asString readStream) hex.
	fileReference := networkRoot / hash / (cacheSize
		ifNil: [ 'original.image' ]
		ifNotNil: [ cacheSize asString, '.jpg' ]).
	^fileReference
]

{ #category : #private }
BlLocalImageCache >> cacheRoot [ 

	^cacheRoot
]

{ #category : #configuration }
BlLocalImageCache >> cacheRoot: aFileReference [

	cacheRoot := aFileReference asFileReference.
	cacheRoot ensureCreateDirectory.
	fileRoot := cacheRoot / 'files'.
	fileRoot ensureCreateDirectory.
	networkRoot := cacheRoot / 'network'.
	networkRoot ensureCreateDirectory.
	self initHousekeeping.
]

{ #category : #private }
BlLocalImageCache >> cacheSizeFor: minImageSize [
	"Answer the cached image size just larger than minImageSize"

	^imageSizes detect: [ :size | minImageSize <= size ]
							ifNone: [ nil ].
	
]

{ #category : #private }
BlLocalImageCache >> defaultImageSizes [
	"Answer the default cache sizes to use, i.e.
	#(200, <in the middle>, <Display max dimension>)"

	| newImageSizes newSize |

	"Start with the larger dimension of the display and divide by 4 down to 200"
	newSize := Display width max: Display height.
	newImageSizes := Array new: 3.
	newImageSizes
		at: 1 put: 200;
		at: 2 put: (newSize // 2);
		at: 3 put: newSize.
	^newImageSizes
]

{ #category : #accessing }
BlLocalImageCache >> fileAt: aFileReference size: minImageSize [
	"Answer the Form for the specified file and requested size.
	If minImageSize isNil, answer the form from the original file.
	Otherwise answer the cached image which is larger than minImageSize."

	| fileReference cacheSize cacheFile form |

	fileReference := aFileReference asFileReference.
	minImageSize ifNil: [ ^self formFor: fileReference ].
	cacheSize := self cacheSizeFor: minImageSize.
	cacheSize ifNil: [ ^self formFor: fileReference ].
	cacheFile := self cacheFileFor: fileReference size: cacheSize.
	cacheFile exists ifTrue: [ 
		hits := hits + 1.
		^self formFor: cacheFile ].
	form := self formFor: fileReference.
	form := form scaledToSize: cacheSize@cacheSize.
	cacheFile parent ensureCreateDirectory.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	housekeeper add: cacheFile.
	misses := misses + 1.
	^form.

]

{ #category : #private }
BlLocalImageCache >> fileRoot [
	"This is only here to facilitate testing"

	^fileRoot
]

{ #category : #manage }
BlLocalImageCache >> flush [ 
	"Remove all cached data from the receiver"

	fileRoot ensureDeleteAllChildren.
	networkRoot ensureDeleteAllChildren.
	housekeeper updateCurrentSize.
]

{ #category : #private }
BlLocalImageCache >> formFor: aFileReference [
	"Answer the form in the specified file"

	^ImageReadWriter gtFormFromBuffer: (self getBufferFor: aFileReference).
]

{ #category : #private }
BlLocalImageCache >> getBufferFor: aFileReference [
	"Answer the contents of the specified file in a ByteArray.
	While this method is synchronous, file access is async"

	| file asyncFile fileSemaphore buffer |

	file := aFileReference asFileReference.
	asyncFile := AsyncFile new.
	fileSemaphore := Semaphore new.
	asyncFile open: file pathString forWrite: false.
	[ asyncFile readByteCount: file size fromFilePosition: 0 onCompletionDo: 
		[ :buf | buffer := buf.  fileSemaphore signal ].
        fileSemaphore wait. ] ensure: [ asyncFile close ].
	"Hack to work around AsyncFile returning a string instead of a ByteArray"
	ByteArray adoptInstance: buffer.
	^buffer
]

{ #category : #accessing }
BlLocalImageCache >> hitRate [
	"Answer the receiver's hit rate"

	^hits / (hits + misses)
]

{ #category : #accessing }
BlLocalImageCache >> hits [
	^ hits
]

{ #category : #private }
BlLocalImageCache >> housekeeper [
	"This is only here to facilitate testing"

	^housekeeper
]

{ #category : #configuration }
BlLocalImageCache >> imageSizes: anArray [
	"Set the image sizes to cache.
	The longer dimension of the image will be the size specified."

	imageSizes := anArray sorted.
]

{ #category : #initialization }
BlLocalImageCache >> initHousekeeping [
	"Set up default housekeeping for the receiver"

	housekeeper := BlImageCacheHousekeeper for: self.
	housekeeper scheduleUpdateCurrentSize.
]

{ #category : #initialization }
BlLocalImageCache >> initialize [

	self maxCacheSize: 100000000. "100MB"
	self imageSizes: self defaultImageSizes.
	hits := 0.
	misses := 0.
]

{ #category : #accessing }
BlLocalImageCache >> maxCacheSize [ 

	^maxCacheSize 
]

{ #category : #configuration }
BlLocalImageCache >> maxCacheSize: anInteger [

	maxCacheSize := anInteger
]

{ #category : #accessing }
BlLocalImageCache >> misses [
	^ misses
]

{ #category : #private }
BlLocalImageCache >> networkRoot [
	"This is only here to facilitate testing"

	^networkRoot
]

{ #category : #initialization }
BlLocalImageCache >> setDefaultLocation [

	self cacheRoot: (FileLocator temp / 'gtoolkit' / 'cache' / 'images') resolve.

]

{ #category : #accessing }
BlLocalImageCache >> taskitRunner [

	^ taskitRunner ifNil: [ taskitRunner := BlHousekeepingWorkerPool ]
]

{ #category : #accessing }
BlLocalImageCache >> taskitRunner: anObject [
	taskitRunner := anObject
]

{ #category : #accessing }
BlLocalImageCache >> url: aUrl size: minImageSize [
	"Answer the Form for the specified URL and requested size.
	If minImageSize isNil, answer the form from the original file.
	Otherwise answer the cached image which is larger than minImageSize."

	| znUrl content fileReference cacheSize cacheFile form |

	znUrl := aUrl asZnUrl.
	"If the appropriate cache entry already exists, just return it.
	Otherwise look for the original. If that doesn't exist, download it."
	minImageSize ifNotNil: [ 
		cacheSize := self cacheSizeFor: minImageSize.
		cacheFile := self cacheFileForUrl: znUrl size: cacheSize.
		cacheFile exists ifTrue: [ 
			hits := hits + 1.
			^self formFor: cacheFile ] ].

	"The cache file doesn't exist or the original has been requested"
	"Ensure we have the original saved to file and its form loaded"
	fileReference := self cacheFileForUrl: znUrl size: nil.
	"Download the original if required"
	fileReference exists ifFalse:
		"Workaround for ZnEasy not being completely general
		(it doesn't handle #file scheme)"
		[ content := znUrl scheme = #file
				ifFalse: [ ZnEasy get: znUrl ]
				ifTrue: [ znUrl asFileReference gtBinaryContents ].
		fileReference parent ensureCreateDirectory.
		fileReference binaryWriteStreamDo: [ :stream |
			stream nextPutAll: content ].
		housekeeper add: fileReference.
		misses := misses + 1.
		form := ImageReadWriter formFromStream: content readStream ]
	ifTrue:
		[ form := self formFor: fileReference ].

	minImageSize ifNil: [ ^self formFor: fileReference ].

	"If the requested cache size is larger than the original, just return the original"
	cacheSize >  form extent max ifTrue: [ ^form ].

	"Answer the form scaled to cacheSize"
	form := form scaledToSize: cacheSize@cacheSize.
	cacheFile parent ensureCreateDirectory.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	housekeeper add: cacheFile.
	misses := misses + 1.
	^form.

]
