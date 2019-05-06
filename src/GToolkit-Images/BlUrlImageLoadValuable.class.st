Class {
	#name : #BlUrlImageLoadValuable,
	#superclass : #BlAsyncImageElementValuable,
	#instVars : [
		'url'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #'instance creation' }
BlUrlImageLoadValuable class >> url: aZnUrl element: aBlElement [

	^self new initializeUrl: aZnUrl element: aBlElement
]

{ #category : #private }
BlUrlImageLoadValuable >> getNewForm [
	"Retrieve the form for the url with an extent the same size or larger than the receiver"

	^BlLocalImageCache current url: url size: self extent max

]

{ #category : #initialization }
BlUrlImageLoadValuable >> initializeUrl: aZnUrl element: aBlElement [

	self initialize.
	url := aZnUrl asZnUrl.
	element := aBlElement
]
