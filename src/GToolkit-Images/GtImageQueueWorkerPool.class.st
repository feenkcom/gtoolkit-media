"
GtImageQueueWorkerPool is a TKTCommonQueueWorkerPool that uses a WaitfreePriorityQueue so that tasks are executed by priority (rather than FIFO).

Public API and Key Messages

The public API and key messages are the same as for TKTCommonWorkerPool.

"
Class {
	#name : #GtImageQueueWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#classVars : [
		'Current'
	],
	#category : #'GToolkit-Images-Model'
}

{ #category : #accessing }
GtImageQueueWorkerPool class >> current [

	^Current ifNil: [ 
		Current := self new
			poolMaxSize: 1;
			start;
			yourself ]
]

{ #category : #acccessing }
GtImageQueueWorkerPool class >> stopCurrent [
	"Stop the default worker pool and remove the reference to it"

	Current ifNil: [ ^self ].
	Current stop.
	Current := nil.
]

{ #category : #initialization }
GtImageQueueWorkerPool >> initialize [ 

	super initialize.
	taskQueue := AtomicSharedPriorityQueue new.
	self name: 'ImageWorker-', self identityHash asString.
]
