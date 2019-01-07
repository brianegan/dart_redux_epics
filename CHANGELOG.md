# 0.10.3

  * Fixes pana issues:
    * Provide longer description
    * Provide example file

# 0.10.2

  * Support latest version of RxDart (0.20.x) (thanks @MichaelMarner!)
  * Add `onChange` stream to EpicStore (thanks @jnorkus)
  * Add docs for combining EpicMiddleware with other Middleware (thanks @Henge9!)

# 0.10.1

  * Fix TypedEpic when not supporting async generators
  
# 0.10.2

  * Add option to async* functions for performance reasons. This option will be removed in the future when Dart supports running async* functions synchronously (https://github.com/dart-lang/sdk/issues/33818) 

# 0.10.0

  * Updated to work with latest version of RxDart, which removes deprecated Stream methods in Dart 2
  
# 0.9.0

  * Now works with Redux 3.0.0 & RxDart 0.16.5, which have been upgraded to work with Dart 2
  
# 0.8.0

  * Breaking Change: Dart 2 Support, Dart 1 supported by 0.7.x
  * Upgrade to RxDart 0.16

# 0.7.0

  * Breaking Change: Actions you emit from your Epic are now re-dispatched through all Epics. They used to be simply forwarded to the next Middleware in the chain.  
  * Added support for `async*` functions
  * Added `TypedEpic` as a convenient way to bind actions of a certain type to an epics.

# 0.6.1

Improve docs, bump to ensure it works with latest RxDart.

# 0.6.0

  * *Breaking Api Changes*
    * Updated to work with Redux 2.0.0
    * `Epic` is now a `typedef`
    * `CombinedEpic` is now `combineEpics`
    
