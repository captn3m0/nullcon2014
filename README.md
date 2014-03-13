browser-extension-security
==========================

This is the source code for my talk on Browse Extension Security which I gave at
nullcon 2014.

##Licence
Released under the MIT Licence.

#Structure
- silent/chrome (Source code for silent extension install in Chrome)
- silent/firefox (Source code for silent extension install in Firefox)
- webstore/chrome/ (Code to download extensions from the chrome webstore, and to
  run a static analysis over them. Results are fed to a mysql database)
- webstore/analysis (code that powers nullcon.captnemo.in)

#Silent Extension Install
This code was written a while back, and does not work with the latest versions of 
either Browser (FF/Chrome), but I belive can be modified and made to work again.

#Release
Since a lot of data is missing from the repo (I didn't feel like committing huge
files), it is availble under the releases section of this repo. Just click
on releases on the right, and you can download manifest files of over 7k extensions,
and a dump of the mysql database generated by the last run of the tool.

These release files are also licenced under MIT.

The paper behind the talk can be accessed [here][arxiv], and the presentations are
available at [speakerdeck][sd]. I wrote a blog post about it [here][blog].