# Blueprint Extensions

Blueprint Extensions adds a few useful utilities for blueprint placement and management:

* Blueprint Updater: While holding a prepared blueprint, press `SHIFT + U` to create a Blueprint Updater.  Drag this
across your screen like you would to make a blueprint and it will create a new blueprint using the same label and icons
as the previous blueprint.  Additionally, if the previous blueprint ended with "v.###", the version number will be
incremented (this behavior can be changed in settings).

* Blueprint Snap: While holding a prepared blueprint, use the numpad (by default) to snap the blueprint to a specific 
  corner or edge.  This is useful if you can't fit a large blueprint entirely on screen and need to make it align 
  against some existing structure -- i.e. for tiling solar layouts.
  
The following would duplicate widely available functionality in other mods and thus is not currently included:
 
 * Blueprint Mirror: Try [Blueprint Flipper and Turner](https://mods.factorio.com/mods/Marthen/Blueprint_Flip_Turn]) or
[Picker Extended](https://mods.factorio.com/mods/Nexela/PickerExtended).
   
## Known Issues
* Blueprint Updaters are tied to the last blueprint you had selected when you created one -- not the blueprint you had
when that specific updater was created.  There currently does not exist a way to associate data with a specific 
updater and still have it function as a selection tool.
  
* Blueprint Snap is unable to factor in the rotation setting due to 
[modding API limitations](https://forums.factorio.com/viewtopic.php?f=28&t=47087&start=80#p324060).  Thus, snapping
to the north edge of a blueprint will snap to the north edge of the blueprint in its native rotation -- not the 
current on-screen one.  The functionality is still fully useable, it just may require a bit of "Which key do I
actually need to hit" confusion.
  
## Unknown Issues

Found a bug?  Please visit the [Issues page](https://github.com/dewiniaid/BlueprintExtensions/issues) to see if it has 
already been reported, and report it at that page if not.  **The Mod Portal does not notify of new posts on the 
discussion page, and messages posted there will likely be ignored.**

 
## Changelog
### 0.2.0 (2018-04-23)
* Added and reworked the blueprint flipping and turning functionality in the Blueprint Flipper and Turner mod,
including a fix to priority splitters.
  * This functionality is disabled if Blueprint Flipper and Turner is enabled to avoid possible conflicts.
  * The GUI buttons for flipping blueprints can be disabled in mod settings.  Note this has no effect if Blueprint Flipper and Turner is disabled.
* Internal reworking of code to be better organized.

### 0.1.1 (2017-12-17)
 
* Added blueprint versioning.
* Fixed a crash when trying to blueprint-update an area with no entities or tiles to blueprint in it.

### 0.1.0 (2017-12-17)
 
* First release, with Blueprint Snap and Blueprint Updater functions.
