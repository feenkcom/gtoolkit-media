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
		'imageSizes'
	],
	#category : #'GToolkit-Images-Cache'
}

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

{ #category : #configuration }
BlLocalImageCache >> cacheRoot: aFileReference [

	cacheRoot := aFileReference asFileReference.
	cacheRoot ensureCreateDirectory.
	fileRoot := cacheRoot / 'files'.
	fileRoot ensureCreateDirectory.
	networkRoot := cacheRoot / 'network'.
	networkRoot ensureCreateDirectory.
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
	cacheFile exists ifTrue: [ ^self formFor: cacheFile ].
	form := self formFor: fileReference.
	form := form scaledToSize: cacheSize@cacheSize.
	PluginBasedJPEGReadWriter putForm: form onFileNamed: cacheFile.
	^form.

]

{ #category : #private }
BlLocalImageCache >> fileRoot [
	"This is only here to facilitate testing"

	^fileRoot
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

{ #category : #configuration }
BlLocalImageCache >> imageSizes: anArray [
	"Set the image sizes to cache.
	The longer dimension of the image will be the size specified."

	imageSizes := anArray sorted.
]

{ #category : #initialization }
BlLocalImageCache >> initialize [

	self maxCacheSize: 500000000. "500MB"
	self imageSizes: self defaultImageSizes.
]

{ #category : #configuration }
BlLocalImageCache >> maxCacheSize: anInteger [

	maxCacheSize := anInteger
]

{ #category : #initialization }
BlLocalImageCache >> setDefaultLocation [

	self cacheRoot: (FileLocator temp / 'gtoolkit' / 'cache' / 'images') resolve.

]
