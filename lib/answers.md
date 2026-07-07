# ENCE 216 – Practical A Answers

**Checkpoint 1:** 
Upon executing a hot-reload, only `build()` prints to the console again because the State object already exists in memory; `initState()` is only called once during the initial instantiation of the widget, whereas `build()` is triggered whenever the framework needs to redraw the UI.

**Section 4 Experiment:** 
Mutating the data array outside of the `setState()` callback successfully alters the underlying values in memory, but it fails to notify the Flutter framework that a change has occurred, meaning the UI is never told to rebuild and reflect those new values.