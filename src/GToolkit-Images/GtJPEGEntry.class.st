Class {
	#name : #GtJPEGEntry,
	#superclass : #Object,
	#instVars : [
		'width',
		'height',
		'scale',
		'form'
	],
	#category : #'GToolkit-Images-JPEG'
}

{ #category : #'instance creation' }
GtJPEGEntry class >> newForm: aForm info: aGtJPEGInfo [

	^self new initializeForm: aForm info: aGtJPEGInfo
]

{ #category : #accessing }
GtJPEGEntry >> form [
	^ form
]

{ #category : #accessing }
GtJPEGEntry >> height [
	^ height
]

{ #category : #initialization }
GtJPEGEntry >> initializeForm: aForm info: aGtJPEGInfo [

	form := aForm.
	width := aGtJPEGInfo width.
	height := aGtJPEGInfo height.
	scale := aGtJPEGInfo scale_num / aGtJPEGInfo scale_denom.
]

{ #category : #accessing }
GtJPEGEntry >> scale [
	^ scale
]

{ #category : #accessing }
GtJPEGEntry >> width [
	^ width
]
