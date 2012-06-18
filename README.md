3D Flow Visualization
=====================

Visualize energy flows as interactive Sankey diagrams.  
Uses [processing.js](http://processingjs.org/), [bootstrap from Twitter](http://twitter.github.com/bootstrap/).

See the [demo](http://thejnich.github.com/DiGraph3D/).

Currently only [Google Chrome](http://www.google.com/chrome) fully supports all features.

Local Development
-----------------
Processing.js is slightly different than standard Processing, in that you can call javascript functions from processing code
and vice versa. Due to this, sketch/sketch.pde will most likely not compile and run in the Processing IDE.  
The easiest way to work on the code is to run in locally in a browser, preferably Chrome.  
To do this you need to run some kind of http server locally, or Chrome will not load the page. The easiest option to just use
pythons SimpleHTTPServer.  
In MacOSX, this can be done as follows, the process will be similar in other environments:
- Clone the repository
- In the terminal navigate to the top level project directory (where index.html lives)
- python -m SimpleHTTPServer
- navigate to localhost:8000 (or whatever port your python module tells you) in Chrome
- Modify code as you like, refresh the page to see changes
- Debug using Chrome developer tools
