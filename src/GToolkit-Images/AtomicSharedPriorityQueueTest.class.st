Class {
	#name : #AtomicSharedPriorityQueueTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #tests }
AtomicSharedPriorityQueueTest >> testNextIfNone [

	| queue |

	"Test removing first element"
	queue := AtomicSharedPriorityQueue new.
	queue
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 0);
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 5);
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 6);
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 8);
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 7);
		nextPut: (AtomicSharedPriorityQueueTestEntry priority: 1).

	self assert: queue nextOrNil priority equals: 0.
	self assert: queue size equals: 5.
	self assert: queue itemCount equals: 5.

	self assert: queue nextOrNil priority equals: 1.
	self assert: queue size equals: 4.
	self assert: queue itemCount equals: 5.

	self assert: queue nextOrNil priority equals: 5.
	self assert: queue size equals: 3.
	self assert: queue itemCount equals: 4.

	self assert: queue nextOrNil priority equals: 6.
	self assert: queue size equals: 2.
	self assert: queue itemCount equals: 3.

	self assert: queue nextOrNil priority equals: 7.
	self assert: queue size equals: 1.
	self assert: queue itemCount equals: 2.

	self assert: queue nextOrNil priority equals: 8.
	self assert: queue size equals: 0.
	self assert: queue itemCount equals: 1.

	self assert: queue nextOrNil isNil.
	self assert: queue size equals: 0.
	self assert: queue itemCount equals: 1.

]
