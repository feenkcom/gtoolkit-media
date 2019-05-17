"
BlLocalImageCacheTestEntry acts as a proxy for ${class:name=BlAsyncImageElement}$ during testing.

"
Class {
	#name : #BlLocalImageCacheTestEntry,
	#superclass : #Object,
	#instVars : [
		'entry'
	],
	#category : #'GToolkit-Images-Tests'
}

{ #category : #accessing }
BlLocalImageCacheTestEntry >> entry [
	^ entry
]

{ #category : #accessing }
BlLocalImageCacheTestEntry >> entry: anObject [
	entry := anObject
]
