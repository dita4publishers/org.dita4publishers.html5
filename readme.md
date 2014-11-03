Dita for Publishers HTML5 plugin
================================

The DITA for Publishers HTML5 plugin makes it possible to generate complete HTML5-based Web sites including all the
supporting Javascript and CSS files. It manages generating the HTML5 source and copying any supporting toolking for
the Web site. You can configure the theme you want or use any HTML5 library or design you prefer.

The HTML5 plugin depends on the following other plugins:

* The [DITA Community org.dita-community.common.html](https://github.com/dita-community/org.dita-community.common.xslt) plugin
* The [D4P org.dita4publishers.common.mapdriven](https://github.com/dita4publishers/org.dita4publishers.common.mapdriven) plugin
* The [D4P org.dita4publishers.common.xslt"](https://github.com/dita4publishers/org.dita4publishers.common.xslt) plugin
* The [D4P org.dita4publishers.json"](https://github.com/dita4publishers/org.dita4publishers.json) plugin

All these plugins are provided in the main DITA for Publishers distribution or you can install each plugin individually.

Installation
------------

There three ways to install the plugin:

  1. Download the [DITA for Publishers main distribution](http://sourceforge.net/projects/dita4publishers/files/) and install it.
  2. Download this repository as a Zip from Github and extract it into your Toolkit's plugins/ directory
  3. Use git to clone this repository into your Toolkit's plugins directory (if you want to be really clever you can
make the Toolkit's plugins/ directory into a git repo and configure each plugin you want to track as a git submodule. See
the DITA for Publishers project wiki for details on how to work with git submodules).

### Additional steps for developers

If you want to do development on top of the HTML5 plugin, you will need to install the YUI compressor.
This tool is used to compress your css and javascripts assets.

* Download the   [YUI compressor version 2.4.7](https://github.com/downloads/yui/yuicompressor/yuicompressor-2.4.7.zip)
* extract the content into the org.dita4publishers.html5 plugin directory

Notes:

* The YUI compressor version 2.4.8 does not work properly on Windows. There is a path resolution issue.
* 3 July 2014 - Due to a java issue, there is no way to have the GET task working properly with ant over SSL on Java 7. I had to remove the YUI compressor installer

Running the transformation
--------------------------

    Using Ant:
    ant -Dargs.input=samples/hierarchy.ditamap -Doutput.dir=out/garage-num -Dtranstype=d4p-html5

    Using Java:
    java -jar lib\dost.jar /i:samples/hierarchy.ditamap /transtype:d4p-html5


Documentation
--------------------------

The documentation has been moved to the main [Dita4Publishers](https://github.com/dita4publishers/dita4publishers) project.


Authors and Contributors
------------------------

* Bertrand Lefort
* Eliot Kimber [Contrext, LLC](http://contrext.com)
* Jim Owens
* Ray Fan [Tweedle](http://www.tweddle.com)
* Mica Semrick [Silent Umbrella](http://www.silentumbrella.com)
