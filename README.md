# chainbuilderapp

ChainBuilder iOS app for tracking your habits. [Read more here](https://chainbuilderapp.morrdusk.net)


## Development notes

```$ pod install
$ open chainbuilder.xcworkspace
```

  Then build and run the chainbuilder-dev target in the simulator.

### Frameworks

#### Logging

Uses the [logkit](http://www.logkit.info) framework for logging. It's added as an embedded framework through a git submodule.

Remember to do `git submodule update --init --recursive` after a fresh clone to get the submodule code.
