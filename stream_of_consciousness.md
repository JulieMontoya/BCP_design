## Thoughts, in no particular order

We need to be able to step through the database, searching for pins connected to a given node.
For each component, we need to step through its pins seeing which node each one is connected to; then
RTS  (saving the current pin and component so we can resume the search)  so we can process it, then
JSR to the "next pin" code  (where we would naturally have landed anyway, if the pin was not connected
to the wanted node)  to continue searching for pins connected to that node.  
