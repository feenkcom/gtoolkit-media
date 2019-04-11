Class {
	#name : #WaitfreePriorityQueueTest,
	#superclass : #TestCase,
	#category : #'GToolkit-Images-Tests'
}

{ #category : #tests }
WaitfreePriorityQueueTest >> testNextIfNone [

	| queue |

	"Test removing first element"
	queue := WaitfreePriorityQueue new.
	queue
		nextPut: (WaitfreePriorityTestEntry priority: 0);
		nextPut: (WaitfreePriorityTestEntry priority: 5);
		nextPut: (WaitfreePriorityTestEntry priority: 6);
		nextPut: (WaitfreePriorityTestEntry priority: 8);
		nextPut: (WaitfreePriorityTestEntry priority: 7);
		nextPut: (WaitfreePriorityTestEntry priority: 1).

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
