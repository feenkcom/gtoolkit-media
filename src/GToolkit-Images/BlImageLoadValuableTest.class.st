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
	element := BlFileImageElement new
					taskitRunner: TKTLocalProcessTaskRunner new;
					size: 200@200.
	"Force the element to look like it is open from the valuable's perspective"
	element instVarNamed: 'bounds' put: (0@0 corner: 200@200).
	"Force single threaded operation of the cache"
	BlLocalImageCache current taskitRunner: TKTLocalProcessTaskRunner new.
	valuable := BlImageLoadValuable file: resources f1 element: element.
	form := valuable getNewForm.
	"Restore normal threaded operation of the cache"
	BlLocalImageCache current taskitRunner: TKTLocalProcessTaskRunner new.
	self assert: form class equals: Form.
	"The dummy element actually has 0 extent, so the original size is preserved."
	self assert: form width equals: 200.
	self assert: form height equals: 200.
]
