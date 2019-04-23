"
GtImageQueueWorkerPool is a TKTCommonQueueWorkerPool that uses a WaitfreePriorityQueue so that tasks are executed by priority (rather than FIFO).

Public API and Key Messages

The public API and key messages are the same as for TKTCommonWorkerPool.

"
Class {
	#name : #BlImageQueueWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-Images-TaskIt'
}

{ #category : #accessing }
BlImageQueueWorkerPool class >> current [

	^Current ifNil: [ 
		Current := self new
			poolMaxSize: 1;
			start;
			yourself ]
]

{ #category : #acccessing }
BlImageQueueWorkerPool class >> stopCurrent [
	<script>
	"Stop the default worker pool and remove the reference to it"

	Current ifNil: [ ^self ].
	Current stop.
	Current := nil.
]

{ #category : #initialization }
BlImageQueueWorkerPool >> initialize [ 

	super initialize.
	taskQueue := AtomicSharedPriorityQueue new.
	self name: 'ImageWorker-', self identityHash asString.
]

{ #category : #printing }
BlImageQueueWorkerPool >> printOn: aStream [
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
