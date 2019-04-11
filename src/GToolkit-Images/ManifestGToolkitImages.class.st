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
