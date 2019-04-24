Class {
	#name : #BlLocalImageCacheTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #tests }
BlLocalImageCacheTest >> testCacheSizeFor [

	| cache requestedSize |

	cache := BlLocalImageCache new.
	self assert: (cache cacheSizeFor: 100) equals: 200.
	self assert: (cache cacheSizeFor: 200) equals: 200.
	requestedSize := cache defaultImageSizes second - 1.
	self assert: (cache cacheSizeFor: requestedSize) equals: cache defaultImageSizes second.
	requestedSize := cache defaultImageSizes second.
	self assert: (cache cacheSizeFor: requestedSize) equals: cache defaultImageSizes second.
	requestedSize := cache defaultImageSizes second + 1.
	self assert: (cache cacheSizeFor: requestedSize) equals: cache defaultImageSizes last.
	requestedSize := cache defaultImageSizes last + 1.
	self assert: (cache cacheSizeFor: requestedSize) isNil.

]

{ #category : #tests }
BlLocalImageCacheTest >> testDeafultImageSizes [

	| defaultSizes |

	defaultSizes := BlLocalImageCache new defaultImageSizes.
	self assert: defaultSizes size equals: 3.
	self assert: defaultSizes first equals: 200.
]
