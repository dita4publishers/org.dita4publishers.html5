*******************************************
This information is intented to developpers
*******************************************

How to build the the css and javascripts
****************************************
The build.xml file contains information to assemble all the javascripts and css of the differents library 
into css and js compressed files.


The plugin will attemps to install the yuicompressor. If it does not work, you will have to install 
a copy at the root directory of this plugin.

1. The Download and unpack in the libs directory
   a version of Yahoo YUI compressor

   http://yuilibrary.com/download/yuicompressor/


2. In the ant.properties files, change the ant properties for the
   path of the jar file and the libraries if necessary

   yui.path = yuicompressor-2.4.7/build/yuicompressor-2.4.7.jar
   lib.dir = yuicompressor-2.4.7/lib


3. run the build

	ant -f build.xml


All files should be aggregated and compressed
