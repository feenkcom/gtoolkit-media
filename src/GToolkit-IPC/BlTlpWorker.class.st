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
		'remote'
	],
	#category : #'GToolkit-IPC'
}

{ #category : #'public access' }
BlTlpWorker >> evaluate: aBlock [

	^remote evaluate: aBlock
]

{ #category : #initialization }
BlTlpWorker >> initialize [ 

	super initialize.
	image := SmalltalkImage current imageFile.
	vm := SmalltalkImage current vmBinary.
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

	| socket port retry |

	socket := Socket new listenOn: 0.
	port := socket localPort.
	socket destroy.
	100 milliSeconds wait.

	process := OSProcess thisOSProcess 
		forkAndExec: vm resolve pathString 
		arguments: { '--headless'.
			image resolve pathString.
			'remotePharo'.
			'--startServerOnPort=', port asString. } 
		environment: nil 
		descriptors: nil.

	300 milliSeconds wait.
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
