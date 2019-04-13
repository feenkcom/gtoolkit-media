Class {
	#name : #BlImageLoadValuableTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #accessing }
BlImageLoadValuableTest class >> resources [ 

	^{ GtImageTestResources. }
]

{ #category : #tests }
BlImageLoadValuableTest >> testValue [

	| valuable resources element |

	resources := GtImageTestResources current.
	element := BlElement new size: 200@200.
	valuable := BlImageLoadValuable file: resources f1 element: element.
	self assert: valuable value class equals: Form.
	"The dummy element actually has 0 extent, so the original size is preserved."
	self assert: valuable form width equals: 7.
	self assert: valuable form height equals: 7.
]
