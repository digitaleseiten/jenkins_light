Jenkins Build Light
===================
 
For the Delcom USB light model 904008

Changes the status of a Delcom USB light depending on the status of a
jenkins build and when pull requests are pending for a repository.

The light is:
- orange untill the data from jenkins arrives for the first time (only happens for about the first 10 seconds after starting jenkins.sh)
- green when the last build was a sucess
- blinky green when a pull request is pending
- blinky blue when jenkins is building (it blinks faster the nearer the build get to completion)
- blinky red when the last build failed

Installation
============

You need to install ruby-usb first

<pre>
prompt$: git clone git@github.com:digitaleseiten/ruby_usb.git
</pre>

<b>Important</b>: Follow the installation instructions in the ruby-usb Readme file.

Then in a seperate folder.

<pre>
prompt$: git clone git@github.com:digitaleseiten/jenkins_light.git
</pre>

Configuration
=============

There are two example.yml files in the root folder. One for Github and one for Jenkins.
Enter in your information and rename them to <b>github_credentials.yml</b> and <b>jenkins_credentials.yml</b> respectivly

Starting
=========

From the root directory of the project, just run

<pre>jenkins_light</pre>

Useful Information
==================

When Jenkins is building, the blink frequesncy of the light increases the closer it gets to the end of a build.
This works because the length of successful builds are captured in a txt file in the data folder.
When building for the first time - you might get a strange blink pattern.

Just to save you some time. There is some code out there for the Delcom light that used the libusb gem from git://github.com/larskanis/libusb.git - The nice thing about that is the libusb is a gem and it uses 1.0 version of libusb (now libusbx) - I would have loved to have used that instead of the ruby-usb which used the libusb-compat (which in turn uses the old version of libusb), but I am on a mac - and in this case its a bad thing. The Jenkins light is a HID device. HID devices get grabbed up by macosx and there is no simple way to get them released. ruby-usb with lib-compat some how got around that on the mac.

Looking for a Job in Berlin?
============================
Drop us a line!!