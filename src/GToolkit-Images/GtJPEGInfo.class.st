"
GtJPEGInfo is an internal component of the JPEG reader.  When calling out to libGtJPEG it will allocate a structure containing information or an error message relating to the image being read.


"
Class {
	#name : #GtJPEGInfo,
	#superclass : #FFIExternalStructure,
	#classVars : [
		'OFFSET_ERROR_MESSAGE',
		'OFFSET_HEIGHT',
		'OFFSET_MAJOR',
		'OFFSET_MINOR',
		'OFFSET_SCALE_DENOM',
		'OFFSET_SCALE_NUM',
		'OFFSET_WIDTH'
	],
	#category : #'GToolkit-Images-JPEG'
}

{ #category : #'field definition' }
GtJPEGInfo class >> fieldsDesc [
	<script: 'self rebuildFieldAccessors'>

	^#(
		uint16 major
		uint16 minor
		uint32 width
		uint32 height
		uint16 scale_num
		uint16 scale_denom
		char*	 error_message)
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> error_message [
	"This method was automatically generated"
	^ExternalData fromHandle: (handle pointerAt: OFFSET_ERROR_MESSAGE) type: ExternalType char asPointerType
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> error_message: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_ERROR_MESSAGE put: anObject getHandle.
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> height [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_HEIGHT
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> height: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_HEIGHT put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> major [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MAJOR
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> major: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MAJOR put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> minor [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MINOR
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> minor: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MINOR put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> scale_denom [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_SCALE_DENOM
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> scale_denom: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_SCALE_DENOM put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> scale_num [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_SCALE_NUM
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> scale_num: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_SCALE_NUM put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> width [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_WIDTH
]

{ #category : #'accessing structure variables' }
GtJPEGInfo >> width: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_WIDTH put: anObject
]
