Extension { #name : #WaitfreeQueue }

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> gtGraphFor: aView [
	<gtView> 

	^aView mondrian 
		title: 'Graph' translated;
		painting: [ :mondrian | self paintGraphWith: mondrian ]
]

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> gtItemsFor: aView [
	<gtView> 
	| aList |

	aList := aView columnedList
		title: 'Items' translated;
		priority: 50;
		items: [ self itemArray ].

	aList column
		title: 'Index' translated;
		width: 30;
		item: [ :eachItem :eachIndex | eachIndex asRopedText foreground: Color gray].
	
	aList column
		title: 'Object' translated;
		item: [ :eachItem :eachIndex | 
			eachItem object == dummy ifTrue: [ '<Zombie>' ] ifFalse: [ eachItem object ] ];
		itemFormat: [ :eachItem | eachItem asString ].
	
	^ aList
]

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> itemArray [
	"Answer an array of the receiver's items, excluding the dummy"

	| item |

	item := dummy.
	^Array streamContents: [ :stream |
		[ item := item next.
		stream nextPut: item.
		item isCircular ] whileFalse ].
]

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> itemCount [
	"Answer the number of items in the queue including dummies. 
	If queue is currently in the middle of extraction by other process, give a (very) approximate answer.
	
	This method having a non-deterministic results, because of nature of concurrent shared queue. 
	"
	
	| item count |

	item := dummy.

	count := 0.
	[ item := item next. item == dummy ifFalse: [ count := count + 1 ]. item isCircular ] whileFalse.

	count = 0 ifTrue: [
		"if queue is locked by other process, check the tail and give a (very) approximate answer."
		^ tail object == dummy ifTrue: [ 0 ] ifFalse: [ 1]
		].	

	^ count
]

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> paintGraphWith: view [

	| itemArray items edges passiveEdges |

	itemArray := self itemArray.
	items := IdentitySet new.
	items add: dummy.
	itemArray do: [ :item |
		items
			add: item;
			add: item object ].
	edges := OrderedCollection new.
	passiveEdges := OrderedCollection new.
	edges add: dummy -> dummy next.
	itemArray do: [ :each |
		edges add: each -> each next.
		each isZombie
			ifTrue: [ passiveEdges add: each -> each object ]
			ifFalse: [ edges add: each -> each object ] ].
	view nodes 
		stencil: [ :node | BlTextElement new 
						text: (node == dummy
									ifTrue: [ 'dummy' ]
									ifFalse: [ node gtDisplayString ]) asRopedText glamorousRegularFont;
						padding: (BlInsets all: 5);
						geometry: BlEllipse new ];
		with: items.
	view edges 
		fromCenterBottom;
		toCenterTop;
		stencil: [ :each | 
			BlParabollaArcElement new 
				border: (BlBorder paint: (Color black alpha: 0.4) width: 2);
				curvatureFraction: 0.2;
				toHead: (BlArrowheadSimpleArrow new
					border: (BlBorder builder paint: (Color black alpha: 0.4); width: 2; build))];
		connect: edges from: #key to: #value;
		passive;
		connect: passiveEdges from: #key to: #value.
	view layout dominanceTree levelDistance: 30 "custom: GtGradNorthHierarchicalLayout new"
		"custom: GtGraphDominanceTreeLayout new".
]

{ #category : #'*GToolkit-Images' }
WaitfreeQueue >> printOn: aStream [

	aStream 
		nextPutAll: self class name;
		nextPutAll: ' with ';
		print: self size;
		nextPutAll: ' from ';
		print: self itemCount;
	 	nextPutAll: ' items' .
]
