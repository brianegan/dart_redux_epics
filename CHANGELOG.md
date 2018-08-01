# 0.7.1

  * Provide option to disable async generator functions (async* functions).
  
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
    
