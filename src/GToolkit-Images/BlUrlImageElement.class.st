Class {
	#name : #BlUrlImageElement,
	#superclass : #BlAsyncImageElement,
	#instVars : [
		'url'
	],
	#category : #'GToolkit-Images-Elements'
}

{ #category : #accessing }
BlUrlImageElement class >> url: aZnUrl [

	^self new url: aZnUrl
]

{ #category : #accessing }
BlUrlImageElement >> maxPoolSize [
	"Answer the maximum number of tasks that can be executed concurrently"

	^5
]

{ #category : #'async processing' }
BlUrlImageElement >> queueEntry [
	"Answer a TaskIt valuable that will update the receiver."

	^BlUrlImageLoadValuable url: url element: self

]

{ #category : #accessing }
BlUrlImageElement >> url [
	^ url
]

{ #category : #accessing }
BlUrlImageElement >> url: aZnUrl [

	url := aZnUrl asZnUrl
]
