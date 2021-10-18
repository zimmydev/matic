<!--
 Copyright (c) 2021 Brandon Zimmerman
 
 This software is released under the MIT License.
 https://opensource.org/licenses/MIT
-->

# TO-DO

## High-priority

## Medium-priorty

- Defer loading bytecode into BEAM until needed in a `run` func body
  - Initial compilation for memoization cannot be avoided, which automatically loads into BEAM (see if the loading can be skipped and deferred using `:code` vs `Code` module)

## Low-priority

- Write plugin creation guide in README
