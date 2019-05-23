Class {
	#name : #BaselineOfGToolkitMedia,
	#superclass : #BaselineOf,
	#category : #BaselineOfGToolkitMedia
}

{ #category : #baseline }
BaselineOfGToolkitMedia >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec package: 'GToolkit-Images'.
		
		spec group: 'default'
			with: #('GToolkit-Images') ]

]
