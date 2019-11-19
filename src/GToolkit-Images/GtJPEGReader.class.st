Class {
	#name : #GtJPEGReader,
	#superclass : #Object,
	#instVars : [
		'file',
		'targetSize',
		'entry'
	],
	#category : #'GToolkit-Images-JPEG'
}

{ #category : #resources }
GtJPEGReader class >> ffiLibrary [ 

	^GtJPEGLibrary 
]

{ #category : #'image reading/writing' }
GtJPEGReader class >> formFromFileNamed: fileName [ 
	"Answer a Form of the image stored in fileName.
	The file must be a JPEG."

	^self formFromFileNamed: fileName sizeFor: nil.
]

{ #category : #'image reading/writing' }
GtJPEGReader class >> formFromFileNamed: fileName sizeFor: targetSize [
	"Answer a Form of the image stored in fileName.
	The size of the form will be a multiple of 1/8th of the on-disk size, just larger than targetSize.
	targetSize is a Point or nil.
	The file must be a JPEG."

	^self new 
		file: fileName;
		targetSize: targetSize;
		nextImage
]

{ #category : #'image reading/writing' }
GtJPEGReader class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('jpg' 'jpeg')
]

{ #category : #accessing }
GtJPEGReader >> entry [ 

	^entry ifNil: [ self getEntry ]
]

{ #category : #accessing }
GtJPEGReader >> ffiLibrary [ 

	^self class ffiLibrary
]

{ #category : #accessing }
GtJPEGReader >> file [
	^ file
]

{ #category : #accessing }
GtJPEGReader >> file: anObject [
	file := anObject asFileReference
]

{ #category : #accessing }
GtJPEGReader >> getEntry [ 

	| request infop imagep image_data status form info |

	request := GtJPEGRequest externalNew.
	request
		major: 1;
		minor: 0.
	targetSize ifNotNil: [ 
		request
			width: targetSize x;
			height: targetSize y ]
	ifNil: [
		request
			width: 0;
			height: 0 ].
	infop := ExternalAddress allocate: 8.
	imagep := ExternalAddress allocate: 8.
	status := self read: file pathString request: request getHandle info: infop buffer: imagep.
	(status = -1 or: [ status < -2 ]) ifTrue: [ self error: 'Unknown error reading file' ].
	info := GtJPEGInfo fromHandle: (infop longPointerAt: 1) getHandle.
	infop free.
	status = -2 ifTrue: [ | msg |
		msg := info error_message fromCString.
		info free.
		imagep free.
		self error: msg ].

	(info major ~= 1 or: [ info minor ~= 0 ])
		ifTrue: [ self error: 'Unexpected version number' ].

	(status = (info width * info height * 4))
		ifFalse: [ self error: 'Data dimensions don''t match' ].
	[ image_data := imagep longPointerAt: 1.
	form := Form extent: info width @ info height depth: 32.
	LibC uniqueInstance memCopy: image_data to: form bits size: status.
	entry := GtJPEGEntry newForm: form info: info ]
		ensure: [ 
			info free.
			imagep free.
			image_data free. ].
	^entry
]

{ #category : #version }
GtJPEGReader >> libraryVersion [
	"Answer the major and minor version numbers of the library"

	| version |

	version := self primLibraryVersion.
	^ { version bitShift: -16. version bitAnd: 16rFFFF. }
]

{ #category : #accessing }
GtJPEGReader >> primLibraryVersion [

	self ffiCall: #(uint32 libgtjpeg_version ())
]

{ #category : #accessing }
GtJPEGReader >> read: filename request: request info: info buffer: buffer [ 

	self ffiCall: #(int read_jpg (String filename, void * request, void * info, void * buffer))
]

{ #category : #accessing }
GtJPEGReader >> targetSize [
	^ targetSize
]

{ #category : #accessing }
GtJPEGReader >> targetSize: anObject [
	targetSize := anObject
]
