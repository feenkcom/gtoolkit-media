Extension { #name : #SeamlessProxy }

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtLocalViewsFor: aView inContext: aContext [
	| title resultingView |
	title := String streamContents: [ :stream |
				stream
					<< 'SeamlessProxy to: ';
					<< self remoteClass name ].
	resultingView := ((aView composite
		views: (self gtViewsInContext: aContext))
		labelled: title).
	^ resultingView
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtProxyFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Proxy' translated;
		priority: 10000;
		items: [ 
			{ 'reference' -> reference. } ];
		column: 'Icon' do: [:aColumn | 
			aColumn 
				itemStencil: [ :aNode |
					| icon |
					icon := ([ aNode value gtInspectorIcon ifNil: [ aNode value class systemIcon ] ]
						on: Error 
						do: [ :error | aView iconNamed: #smallWarningIcon ]).
					icon asElement 
						margin: (BlInsets top: 3 left: 0 bottom: 3 right: 0 ) ];
				noResize ];
		column: 'Variable' do: [:aColumn |
			aColumn 
				itemFormat: [ :aNode | aNode key asRopedText ];
				matchParent ];
		column: 'Value' do: [ :aColumn |
			aColumn 
				itemFormat: [ :aNode |
					[ aNode value gtDisplayString asRopedText ] 
						on: Error, Halt
						do: [ aNode errorMessage asRopedText foreground: Color red ] ];
			matchParent ];
		send: #value
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtProxyViewsFor: aView [
	<gtView>
	^ aView list
		title: 'Proxy views' translated;
		priority: 10001;
		items: [ 
			self gtDeclarativeViewAccessors ];
		itemFormat: [ :aViewAccessor | aViewAccessor title ];
		send: [ :aViewAccessor | GtDeclarativeView accessor: aViewAccessor ]
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtViewsFor: aView [
	"this is the default entry method for retrieving the wrapper view containing all views"
	^ self gtViewsFor: aView inContext: nil
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtViewsFor: aView inContext: aContext [
	"Add the declarative views from the inspectors object to the inspectors views"

	| resultingView views declaration |

	resultingView := self gtLocalViewsFor: aView inContext: aContext.
	views := resultingView originalView views.

	"Add the explicitly declarative views from the inspected object"
	views addAll: (self gtDeclarativeViewAccessors collect: [ :each |
		"Retrieve the JSON string declaration and instantiate the actual declarative view"
		declaration := GtDeclarativeView accessor: each.
		declaration viewFor: aView ]).

	"Re-sort by priority"
	views := views sorted: [ :a :b | a priority < b priority ].
	resultingView originalView views: views.
	^resultingView
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtViewsInContext: aContext [
	"This collects all views for the current object.
	For a SeamlessProxy we just want the Raw view renamed as 'Proxy'"
	^ OrderedCollection 
		with: (self gtProxyFor: GtPhlowEmptyView new)
		with: (self gtProxyViewsFor: GtPhlowEmptyView new)
]

{ #category : #'*GToolkit-IPC' }
SeamlessProxy >> gtdViewForSelector: aSelector [
	"Answer an accessor for the view created by the given selector."
	| view  declaration |
	view := self gtdDeclarativeViewForSelector: aSelector.
	declaration := GtDeclarativeView accessor: view.
	^ declaration viewFor: GtPhlowEmptyView new
]
