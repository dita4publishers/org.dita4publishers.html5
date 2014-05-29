Dita for Publishers HTML5 plugin
================================

May 2014: Please note that this repository is a way to share code for developpers. The project is not 100% completed and won't be before a couple of months. It is a good start if you have nothing.

This repository is a temporary repository for the development of the DITA for Publishers HTML5 plugin.

Introduction
------------

If you have no idea of what DITA is, you should first read [Introduction to the Darwin Information Typing Architecture
](http://www.ibm.com/developerworks/library/x-dita1/) or [google Introduction to DITA](https://www.google.ca/?gfe_rd=cr&ei=w6zBUonhIqGC8QeXgoHABw#q=introduction+to+DITA)

If you are interested in this plugin, please:
Read the [Dita for publishers documentation](http://dita4publishers.sourceforge.net/d4p-user-guide/).
Install the [DITA for publishers project](http://sourceforge.net/projects/dita4publishers/).

Installation
------------

* Install the dita4publishers-0.9.19_OT17RC10.zip from [http://sourceforge.net/projects/dita4publishers/files/release-candidate/](http://sourceforge.net/projects/dita4publishers/files/release-candidate/)

* Download the latest release under the releases tabs, and extract it

* Unzip this so that the net.sourceforge.dita4publishers.html5 subdirectory
is a child of the DITA-OT plugins or demo directory (e.g. C:\DITA-OTx.y\plugins\), and
you should be ready to go.

Running the transformation
--------------------------

    Using Ant:
    ant -Dargs.input=samples/hierarchy.ditamap -Doutput.dir=out/garage-num -Dtranstype=d4p-html5

    Using Java:
    java -jar lib\dost.jar /i:samples/hierarchy.ditamap /transtype:d4p-html5

Authors and Contributors
------------------------
A big thanks to:

* Eliot Kimber [Contrext, LLC](http://contrext.com)
* Jim Owens
* Ray Fan [Tweedle](http://www.tweddle.com)
* Mica Semrick [Silent Umbrella](http://www.silentumbrella.com)
