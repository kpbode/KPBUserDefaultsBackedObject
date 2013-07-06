KPBUserDefaultsBackedObject
===========================

A sample project to show how a class with dynamic properties is being implemented. The Project contains a class **KPBAppPreferences** which declares sample properties which are stored to **NSUserDefaults**. **KPBUserDefaultsBackedObject** contains the implementation for dynamic method resolution and adds method implementations dynamically as required. Each property is backed by **NSUserDefaults**, the keys used to store and read data are resolved from the property name. Objects can be initialised as **singletons** or with a **uniqueIdentifier**. All objects of a class are grouped in **NSUserDefaults**
