"
BlTlpWorker represents a single image that can be delegated tasks to evaluate.

BlTlpWorker is responsible for starting and stopping the OS process running the TelePharo remote server.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
!!Internal Representation and Key Implementation Points.

!!!Instance Variables
	image:		<FileReference>	The pharo image used to run the server
	process:		<ExternalOSProcess>		The OS process running the server
	remote:		<TlpRemotePharo>		The Tlp proxy representing the server
	vm:		<FileReference>		The pharo VM used to run the server


    Implementation Points
"
Class {
	#name : #BlTlpWorker,
	#superclass : #Object,
	#instVars : [
		'image',
		'vm',
		'process',
		'remote',
		'port'
	],
	#category : #'GToolkit-IPC'
}

{ #category : #private }
BlTlpWorker >> arguments [ 
	"Answer the arguments used to run the worker"

	^{ '--headless'.
			image resolve pathString.
			'remotePharo'.
			'--startServerOnPort=', self port asString. }
]

{ #category : #private }
BlTlpWorker >> command [
	"Answer the command used to run the worker"

	^vm resolve pathString
]

{ #category : #private }
BlTlpWorker >> commandString [
	"Convenience method, answer the equivalent shell command string for starting the worker"

	^self command, ' ', (' ' join: self arguments)
]

{ #category : #private }
BlTlpWorker >> connectToWorker [
	"Open the TelePharo connection to the worker"

	| retry |

	retry := 0.
	[ remote := TlpRemoteIDE connectTo: (TCPAddress ip: #[127 0 0 1] port: port) ]
		on: ConnectionTimedOut 
		do: [ :ex |
			retry := retry + 1.
			retry <= 10 ifTrue: [
				500 milliSeconds wait.
				ex retry ]
			ifFalse:
				[ ex signal ] ].

]

{ #category : #'public access' }
BlTlpWorker >> evaluate: aBlock [

	^remote evaluate: aBlock
]

{ #category : #private }
BlTlpWorker >> getFreePort [
	"Answer a free port number to start the server on"

	| socket |

	socket := Socket new listenOn: 0.
	port := socket localPort.
	socket destroy.
	100 milliSeconds wait.
	^port
]

{ #category : #initialization }
BlTlpWorker >> initialize [ 

	super initialize.
	image := SmalltalkImage current imageFile.
	vm := SmalltalkImage current vmBinary.
]

{ #category : #accessing }
BlTlpWorker >> port [ 
	"Answer the port used to run the worker"

	^port ifNil: [ port := self getFreePort ]
]

{ #category : #printing }
BlTlpWorker >> printOn: aStream [

	| attributes |

	super printOn: aStream.
	attributes := Array streamContents: [ :attrs |
		(process isNil and: [remote isNil]) ifTrue: 
			[ attrs nextPut: 'idle' ].
		process ifNotNil: [ 
			attrs nextPut: 'pid=', process pid printString ].
		remote ifNotNil: [ 
			attrs nextPut: 'port=', remote remotePeer address port printString ] ].
	aStream 
		<< '(';
		<< (', ' join: attributes);
		<< ')'.
]

{ #category : #running }
BlTlpWorker >> start [
	"Get a free port and fork the worker"

	self startWorkerProcess.
	self connectToWorker.

]

{ #category : #private }
BlTlpWorker >> startWorkerProcess [
	"Start the worker process"

	process := OSProcess thisOSProcess 
		forkAndExec: self command 
		arguments:  self arguments
		environment: nil 
		descriptors: nil.

	300 milliSeconds wait.

]

{ #category : #running }
BlTlpWorker >> stop [

	remote ifNotNil: [ 
		remote quit.
		remote := nil.
		100 milliSeconds wait. ].
	process ifNotNil: [ 
		process terminate.
		process := nil ].
]
