Jenkins Build Light
===================

For the Delcom USB light model 904008

Changes the status of a Delcom USB light depending on the status of a
Jenkins build and when pull requests are pending for a repository.

The light statuses:
- Off until the data from Jenkins arrives for the first time (only happens for about the first 10 seconds after starting the jenkins_light program)
- Off when you abort the build
- Green when the last build was a sucess
- Blinky Green when a pull request is pending
- Blinky Blue when Jenkins is building (it blinks faster the nearer the build get to completion)
- Blinky Red when the last build failed
- Orange when is does now understand the Jenkins status (unlikely but possible)

Some times you want the light to turn off (maybe because it is driving you crazy blinking red since the last build failed),
of course you could just unplug it, bit where is the fun in that - so instead, just send it either an email with
shut up or wake up in the subject to turn it off, or back on again.

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

There are three example.yml files in the root folder. One for Github and one for Jenkins.
Enter in your information and rename them to <b>github_credentials.yml</b>, <b>jenkins_credentials.yml</b>
and <b>gmail_credentials.yml</b> respectively. (I am sure that i works for all other pop mail providers, but I only tried it out with gmail)

NOTE: If you don't want to use the github or the gmail feature, then you can disable them in your github_credentials.yml and
gmail_credentials.yml files.

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