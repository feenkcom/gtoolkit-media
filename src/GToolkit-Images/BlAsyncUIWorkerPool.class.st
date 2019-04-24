"
GtImageQueueWorkerPool is a TKTCommonQueueWorkerPool that uses a WaitfreePriorityQueue so that tasks are executed by priority (rather than FIFO).

Public API and Key Messages

The public API and key messages are the same as for TKTCommonWorkerPool.

"
Class {
	#name : #BlAsyncUIWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #accessing }
BlAsyncUIWorkerPool class >> current [

	^Current ifNil: [ 
		Current := self new
			poolMaxSize: 1;
			start;
			yourself ]
]

{ #category : #scheduling }
BlAsyncUIWorkerPool class >> schedule: aValuable [
	"Schedule the supplied valuable in the current worker pool"

	TKTConfiguration processProvider: BlTKTBackgroundProcessProvider new during: [ 
		self current schedule: aValuable ].

]

{ #category : #acccessing }
BlAsyncUIWorkerPool class >> stopCurrent [
	<script>
	"Stop the default worker pool and remove the reference to it"

	Current ifNil: [ ^self ].
	Current stop.
	Current := nil.
]

{ #category : #initialization }
BlAsyncUIWorkerPool >> initialize [ 

	super initialize.
	taskQueue := AtomicSharedPriorityQueue new.
	self name: 'ImageWorker-', self identityHash asString.
]

{ #category : #printing }
BlAsyncUIWorkerPool >> printOn: aStream [
	| freeWorkers | 
	freeWorkers := workers select: #isFree.
	aStream
		nextPutAll: self class name;
		nextPutAll: '(';
		nextPutAll: 'name:';
		nextPutAll: name;
		nextPutAll: 'poolMaxSize: ';
		print: poolMaxSize;
		nextPutAll: '; busyWorkers: ';
		print: workers size - freeWorkers size;
		nextPutAll: '; freeWorkers: ';
		print: freeWorkers size;
		nextPutAll: ')'
]
