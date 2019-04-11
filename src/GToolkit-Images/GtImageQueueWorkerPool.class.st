"
GtImageQueueWorkerPool is a TKTCommonQueueWorkerPool that uses a GtImageLoadQueue so that tasks are executed by priority (rather than FIFO).

Public API and Key Messages

The public API and key messages are the same as for TKTCommonWorkerPool.

"
Class {
	#name : #GtImageQueueWorkerPool,
	#superclass : #TKTCommonQueueWorkerPool,
	#category : #'GToolkit-Images-Model'
}

{ #category : #initialization }
GtImageQueueWorkerPool >> initialize [ 

	super initialize.
	taskQueue := WaitfreePriorityQueue new.
	self name: 'ImageWorker-', self identityHash asString.
]
