Class {
	#name : #GtImageLoadValuableTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #accessing }
GtImageLoadValuableTest class >> resources [ 

	^{ GtImageTestResources. }
]

{ #category : #tests }
GtImageLoadValuableTest >> testValue [

	| valuable resources |

	resources := GtImageTestResources current.
	valuable := GtImageLoadValuable file: resources f1 displayWidth: 600 height: 400.
	self assert: valuable value class equals: Form.
	"The form is actually square, and the scaling preserves the aspect ratio"
	self assert: valuable value width equals: 400.
	self assert: valuable value height equals: 400.
]
