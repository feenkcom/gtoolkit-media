"
GToolkit-Images provides functionality for efficiently loading images for display.  In particular (the intention is):

- Images are loaded in a background process, leaving the main UI process responsive.
- Image load order is reprioritised as windows are opened, closed and scrolled.
- Images can be loaded from disk or the network.
- Whether the main images is loaded and scaled, or a thumbnail is used, is determined by a set of rules (to be determined).

"
Class {
	#name : #ManifestGToolkitImages,
	#superclass : #PackageManifest,
	#category : #'GToolkit-Images-Manifest'
}

{ #category : #'code-critics' }
ManifestGToolkitImages class >> ruleRBRefersToClassRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#BlLocalImageCache #fileAt:size:for: #false)) #'2019-05-17T07:15:20.731634+02:00') )
]

{ #category : #'code-critics' }
ManifestGToolkitImages class >> ruleRBUnaryAccessingMethodWithoutReturnRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#BlMemoryImageCache #flush #false)) #'2019-07-30T08:15:40.267586+02:00') )
]
