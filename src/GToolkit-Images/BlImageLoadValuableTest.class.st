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

	| valuable resources element entry |

	resources := BlImageTestResources current.
	element := BlFileImageElement new
					taskitRunner: TKTLocalProcessTaskRunner new;
					size: 200@200.
	"Force the element to look like it is open from the valuable's perspective"
	element instVarNamed: 'bounds' put: (0@0 corner: 200@200).
	"Force single threaded operation of the cache and update the current size"
	BlLocalImageCache current taskitRunner: TKTLocalProcessTaskRunner new.
	BlLocalImageCache current housekeeper updateCurrentSize.

	valuable := BlFileImageLoadValuable file: resources f1 element: element.
	entry := valuable getNewEntry.

	"Restore normal threaded operation of the cache"
	BlLocalImageCache current taskitRunner: TKTLocalProcessTaskRunner new.

	self assert: entry class equals: BlImageCacheEntry.
	"The source form is only 7@7, so the original will be returned."
	self assert: entry form width equals: 7.
	self assert: entry form height equals: 7.
	self assert: entry isOriginal.
	self assert: entry isSmallest.
]
