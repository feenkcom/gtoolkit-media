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

	| cacheSize |

	minImageSize ifNil: [ ^self formFor: aFileReference ].
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

{ #category : #initialization }
BlLocalImageCache >> initialize [ 

	self cacheRoot: (FileLocator temp / 'gtoolkit' / 'cache' / 'images') resolve.
	self maxCacheSize: 500000000. "500MB"
	"self setDefaultImageSizes."
]

{ #category : #configuration }
BlLocalImageCache >> maxCacheSize: anInteger [

	maxCacheSize := anInteger
]
