Class {
	#name : #BlImageCacheEntry,
	#superclass : #Object,
	#instVars : [
		'form',
		'isSmallest',
		'isOriginal'
	],
	#category : #'GToolkit-Images-Cache'
}

{ #category : #accessing }
BlImageCacheEntry >> form [
	^ form
]

{ #category : #accessing }
BlImageCacheEntry >> form: anObject [
	form := anObject
]

{ #category : #accessing }
BlImageCacheEntry >> isOriginal [
	^ isOriginal
]

{ #category : #accessing }
BlImageCacheEntry >> isOriginal: anObject [
	isOriginal := anObject
]

{ #category : #accessing }
BlImageCacheEntry >> isSmallest [
	^ isSmallest
]

{ #category : #accessing }
BlImageCacheEntry >> isSmallest: anObject [
	isSmallest := anObject
]
