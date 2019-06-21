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
	cacheRoot:		<FileReference>
	fileRoot:		<FileReference>
	imageSizes:		<Array>
	maxCacheSize:		<Integer>  The maximum size of the cache in bytes.  The actual size may grow somewhat larger than specified in a busy system.
	networkRoot:		<FileReference>
	housekeeper:		<BlImageCacheHousekeeper>
	hits:								<Integer>
	misses:						<Integer>


!!!Implementation Points

To allow lookup in the file system cache to be quick either an index has to be held in memory or the cache entries found quickly.

The current assumption is that the memory cost of an in-memory index is too high.

Scanning a directory looking for files is slow - Pharo always walks over all the files in the directory and matches the file name.  Determining whether a given file exists is fast, a single plugin primitive call.

So we want the cache structure to allow lookup to be determined on the basis of a known file / directory existing or not.  The chosen structure is:

	fileRoot / <path to image> / <image file name> / <cache entry name>.jpg

The directory containing the cache entries can then easily be tested for existence.

To maximise the cache speed, no attempt is made to the cache thread safe.  The side affect is that the cache sizes are approximate and that the cache may actually grow larger than the specified constraints in a busy system.
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

	^Current ifNil: [ 	Current := self default setDefaultLocation ]
]

{ #category : #accessing }
BlLocalImageCache class >> default [ 
	"Answer the default instance to use.
	If worker images are available, they will be used, otherwise everything will be done in-image"

	^(Smalltalk hasClassNamed: #BlTlpWorkerPool)
		ifTrue: [ BlWorkerImageCache new ]
		ifFalse: [ BlLocalImageCache new ]
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

{ #category : #managing }
BlLocalImageCache class >> useLocalImageCache [
	"Force the use of BlLocalImageCache"
	<script>

	self stopCurrent.
	Current := BlLocalImageCache new setDefaultLocation.
]

{ #category : #private }
BlLocalImageCache >> answerForm: aForm size: aSize isOriginal: isOriginal [

	^BlImageCacheEntry new
		isSmallest: (aSize <= imageSizes first);
		isOriginal: isOriginal;
		form: aForm;
		yourself
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
	self ensureCreateDirectory: cacheRoot.
	fileRoot := cacheRoot / 'files'.
	self ensureCreateDirectory: fileRoot.
	networkRoot := cacheRoot / 'network'.
	self ensureCreateDirectory: networkRoot.
	self initHousekeeping.
]

{ #category : #private }
BlLocalImageCache >> cacheSizeFor: minImageSize [
	"Answer the cached image size just larger than minImageSize"

	minImageSize ifNil: [ ^nil ].
	^imageSizes detect: [ :size | minImageSize <= size ]
							ifNone: [ nil ].
	
]

{ #category : #manage }
BlLocalImageCache >> clearStats [

	hits := misses := 0.
]

{ #category : #accessing }
BlLocalImageCache >> currentSize [ 
	"Answer the approximate size of the receiver"

	^housekeeper currentSize
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

{ #category : #private }
BlLocalImageCache >> emergencySize [
	"Answer the emergency size at which the cache will be pruned by calling process"

	^housekeeper emergencySize
]

{ #category : #'accessing - cache' }
BlLocalImageCache >> ensureCacheFileForFile: aFileReference size: minImageSize [
	"Ensure that the appropriate cache file entry has been created and answer the file reference or nil if no cache entry applies"

	| fileReference cacheSize cacheFile form |

	fileReference := aFileReference asFileReference.
	cacheSize := self cacheSizeFor: minImageSize.
	(minImageSize isNil or: [ cacheSize isNil ]) ifTrue: [ ^nil ].
	cacheFile := self cacheFileFor: fileReference size: cacheSize.
	cacheFile exists ifTrue: [ ^cacheFile ].
	form := self formFor: fileReference.
	cacheSize >= form extent max ifTrue: [ ^nil ].
	form := form scaledToSize: cacheSize@cacheSize.
	self ensureCreateDirectory: cacheFile parent.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	housekeeper add: cacheFile.
	^cacheFile.

]

{ #category : #private }
BlLocalImageCache >> ensureCreateDirectory: aFileReference [
	"Create the supplied directory ignoring DirectoryExist exceptions
	(on the assumption that the same path is being created by another worker process)"

	| count |

	count := 0.
	[ aFileReference ensureCreateDirectory ]
		on: DirectoryExists 
		do: [ :ex | count := count + 1.
			count <= 3 ifTrue: [ 
				50 milliSeconds wait.
				ex retry ] ]

]

{ #category : #'accessing - cache' }
BlLocalImageCache >> fileAt: aFileReference size: minImageSize for: anObject [
	"Answer the Form for the specified file and requested size.
	If minImageSize isNil, answer the form from the original file.
	Otherwise answer the cached image which is larger than minImageSize."

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
	form := self formFor: fileReference.
	cacheSize >= form extent max ifTrue: 
		[ ^self set: anObject form: form size: form extent max isOriginal: true ].
	form := form scaledToSize: cacheSize@cacheSize.
	self ensureCreateDirectory: cacheFile parent.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	housekeeper add: cacheFile.
	misses := misses + 1.
	^self set: anObject form: form size: cacheSize isOriginal: false.

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
	self clearStats.
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

{ #category : #inspecting }
BlLocalImageCache >> gtStatusFor: aView [
	<gtView>
	| aList |

	aList := aView columnedList 
		title: 'Status' translated;
		priority: 50;
		items: [ { 
			'Current Size (approx.)' -> self currentSize humanReadableSIByteSize.
			'Max Cache Size' -> maxCacheSize humanReadableSIByteSize.
			'Target Size' -> self targetSize humanReadableSIByteSize.
			'Emergency Size' -> self emergencySize humanReadableSIByteSize.
			'Hits' -> self hits asString.
			'Misses' -> self misses asString.
			'Total Accesses' -> self totalAccesses asString.
			'Hit Rate' -> ((self hitRate * 100) rounded asString, '%').
			 } ].

	aList column 
		title: 'Parameter' translated;
		width: 150;
		item: [ :eachItem :eachIndex | eachItem key ].

	aList column 
		title: 'Value' translated;
		width: 70;
		item: [ :eachItem :eachIndex | eachItem value ].

	^aList
]

{ #category : #accessing }
BlLocalImageCache >> hitRate [
	"Answer the receiver's hit rate"

	| totalAccesses |

	totalAccesses := self totalAccesses.
	^totalAccesses = 0
		ifTrue: [ 0 ]
		ifFalse: [ hits asFloat / totalAccesses asFloat ]
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

{ #category : #private }
BlLocalImageCache >> set: anObject form: aForm size: anInteger isOriginal: aBoolean [
	"Set the entry in anObject with the supplied information"

	^anObject entry: (self answerForm: aForm size: anInteger isOriginal: aBoolean)
]

{ #category : #initialization }
BlLocalImageCache >> setDefaultLocation [

	self cacheRoot: (FileLocator temp / 'gtoolkit' / 'cache' / 'images') resolve.

]

{ #category : #private }
BlLocalImageCache >> targetSize [
	"Answer the target size when pruning the cache"

	^housekeeper targetSize
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
BlLocalImageCache >> totalAccesses [

	^hits + misses
]

{ #category : #'accessing - cache' }
BlLocalImageCache >> url: aUrl size: minImageSize for: anObject [
	"Answer the Form for the specified URL and requested size.
	If minImageSize isNil, answer the form from the original file.
	Otherwise answer the cached image which is larger than minImageSize."

	| znUrl content fileReference cacheSize cacheFile form originalSize |

	znUrl := aUrl asZnUrl.
	"If the appropriate cache entry already exists, just return it.
	Otherwise look for the original. If that doesn't exist, download it."
	minImageSize ifNotNil: [ 
		cacheSize := self cacheSizeFor: minImageSize.
		cacheFile := self cacheFileForUrl: znUrl size: cacheSize.
		cacheFile exists ifTrue: [ 
			hits := hits + 1.
			^self set: anObject form: (self formFor: cacheFile) size: cacheSize isOriginal: false ] ].

	"The cache file doesn't exist or the original has been requested"
	"Ensure we have the original saved to file and its form loaded"
	fileReference := self cacheFileForUrl: znUrl size: nil.
	"Download the original if required"
	fileReference exists ifFalse:
		"Workaround for ZnEasy not being completely general
		(it doesn't handle #file scheme)"
		[ content := znUrl scheme = #file
				ifFalse: [ (ZnEasy get: znUrl) entity bytes ]
				ifTrue: [ znUrl asFileReference gtBinaryContents ].
		self ensureCreateDirectory: fileReference parent.
		fileReference binaryWriteStreamDo: [ :stream |
			stream nextPutAll: content ].
		housekeeper add: fileReference.
		misses := misses + 1.
		form := ImageReadWriter formFromStream: content readStream ]
	ifTrue:
		[ form := self formFor: fileReference ].
	originalSize := form extent max.

	minImageSize ifNil: [ ^self set: anObject form: form size: originalSize isOriginal: true ].

	"If the requested cache size is larger than the original, just return the original"
	cacheSize >= form extent max ifTrue: [ ^self set: anObject form: form size: originalSize isOriginal: true ].

	"Answer the form scaled to cacheSize"
	form := form scaledToSize: cacheSize@cacheSize.
	self ensureCreateDirectory: cacheFile parent.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	housekeeper add: cacheFile.
	misses := misses + 1.
	^self set: anObject form: form size: cacheSize isOriginal: false.

]
