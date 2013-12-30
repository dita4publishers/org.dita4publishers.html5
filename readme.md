Dita for Publishers HTML5 plugin
================================
This repository is a temporary repository for the development of the DITA for Publishers HTML5 plugin.

Installation
------------

If you have no idea of what DITA is, you should first read [Introduction to the Darwin Information Typing Architecture
](http://www.ibm.com/developerworks/library/x-dita1/) or [google Introduction to DITA](https://www.google.ca/?gfe_rd=cr&ei=w6zBUonhIqGC8QeXgoHABw#q=introduction+to+DITA)

If you are interested in this plugin, please:
Read the [Dita for publishers documentation](http://dita4publishers.sourceforge.net/d4p-user-guide/).
Install the [DITA for publishers project](http://sourceforge.net/projects/dita4publishers/).

Get the latest version of this plugin
-------------------------------------
* download the latest release under the releases tabs, and extract it

Unzip this so that the net.sourceforge.dita4publishers.html5 subdirectory
is a child of the DITA-OT plugins or demo directory (e.g. C:\DITA-OTx.y\plugins\), and
you should be ready to go.

Running the transformation
--------------------------
Using Ant:
ant -Dargs.input=samples/hierarchy.ditamap -Doutput.dir=out/garage-num -Dtranstype=html5

Using Java:
java -jar lib\dost.jar /i:samples/hierarchy.ditamap /transtype:html5

