Class {
	#name : #BlImageLoadValuableTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #accessing }
BlImageLoadValuableTest class >> resources [ 

	^{ BlImageTestResources. }
]

{ #category : #tests }
BlImageLoadValuableTest >> testValue [

	| valuable resources element form |

	resources := BlImageTestResources current.
	element := BlFileImageElement new size: 200@200.
	valuable := BlImageLoadValuable file: resources f1 element: element.
	form := valuable getNewForm.
	self assert: form class equals: Form.
	"The dummy element actually has 0 extent, so the original size is preserved."
	self assert: form width equals: 7.
	self assert: form height equals: 7.
]
