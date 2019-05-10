"
BlUrlImage is a Bloc element for displaying images:

- Images are loaded and resized on a low (Process) priority queue so that UI responsiveness is maintained.
- Images are loaded in priority based on: 
-- A manually specified priority 
-- Whether they are visible or,
-- How far they are from the visible area.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	bitmap:		<Object>
	file:		<FileReference>
	form:		<Form>
	url:		<String>
	priority: <Integer>  The queue priority to use. nil for default.  0 is highest priority.


    Implementation Points

- The are multiple tradeoffs between memory consumption, memory management (impact on the memory management system, particularly garbage collection) and CPU usage.   Currently the decision when to reload the Form is hard coded in ${method:name=BlUrlImage>>#needsNewForm}$.
"
Class {
	#name : #BlFileImageElement,
	#superclass : #BlAsyncImageElement,
	#instVars : [
		'file'
	],
	#category : #'GToolkit-Images-Elements'
}

{ #category : #accessing }
BlFileImageElement class >> file: aFileReference [

	^self new file: aFileReference
]

{ #category : #accessing }
BlFileImageElement >> file [ 

	^file
]

{ #category : #accessing }
BlFileImageElement >> file: aFileReference [
	"Load the supplied file in the background processor (which will update the receiver when done)"

	file := aFileReference asFileReference.
	self clearForm.
	self queueAsyncUpdate
]

{ #category : #accessing }
BlFileImageElement >> queueEntry [
	"Answer a TaskIt valuable that will update the receiver."

	^BlFileImageLoadValuable file: file element: self

]
