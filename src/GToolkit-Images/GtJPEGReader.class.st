Class {
	#name : #GtJPEGReader,
	#superclass : #Object,
	#instVars : [
		'file',
		'targetSize'
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
GtJPEGReader >> nextImage [ 

	| request infop info imagep image_data status form |

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
	infop := ExternalAddress gcallocate: 8.
	imagep := ExternalAddress gcallocate: 8.
	status := self read: file pathString request: request getHandle info: infop buffer: imagep.
	(status = -1 or: [ status < -2 ]) ifTrue: [ self error: 'Unknown error reading file' ].
	info := GtJPEGInfo fromHandle: (infop longPointerAt: 1) getHandle.
	status = -2 ifTrue: [ self error: info error_message fromCString ].

	(info major ~= 1 or: [ info minor ~= 0 ])
		ifTrue: [ self error: 'Unexpected version number' ].

	(status = (info width * info height * 4))
		ifFalse: [ self error: 'Data dimensions don''t match' ].
	[ image_data := imagep longPointerAt: 1.
	form := Form extent: info width @ info height depth: 32.
	LibC uniqueInstance memCopy: image_data to: form bits size: status ]
		ensure: [
			info free.
			image_data free. ].
	^form.
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
