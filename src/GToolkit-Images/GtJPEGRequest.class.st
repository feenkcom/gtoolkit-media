"
GtJPEGRequest is a memory structure that is used to pass information to the library about processing to be performed on the image before answering it. 

Currently only image scaling is supported (by specifying the target width and height).


"
Class {
	#name : #GtJPEGRequest,
	#superclass : #FFIExternalStructure,
	#classVars : [
		'OFFSET_HEIGHT',
		'OFFSET_MAJOR',
		'OFFSET_MINOR',
		'OFFSET_UNUSED',
		'OFFSET_WIDTH'
	],
	#category : #'GToolkit-Images-JPEG'
}

{ #category : #'field definition' }
GtJPEGRequest class >> fieldsDesc [
	<script: 'self rebuildFieldAccessors'>

	^#(
		uint32 major
		uint32 minor
		uint32 width
		uint32 height
		uint32 unused)
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> height [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_HEIGHT
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> height: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_HEIGHT put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> major [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_MAJOR
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> major: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_MAJOR put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> minor [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_MINOR
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> minor: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_MINOR put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> unused [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_UNUSED
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> unused: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_UNUSED put: anObject
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> width [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_WIDTH
]

{ #category : #'accessing structure variables' }
GtJPEGRequest >> width: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_WIDTH put: anObject
]
