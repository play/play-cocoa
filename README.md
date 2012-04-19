# Play Cocoa!

This project houses both the Cocoa driven [Play](https://github.com/play/play) clients. It consists of two actual application targets: Play Item and Play iOS.

## Application Targets

Play Item lives in the menu bar of your Mac. Play iOS runs on iPhone and iPad.

### Play Item

Play Item is a streaming client for Play that runs on Mac OS X 10.7 and up. It simply lives in your menu bar allowing you to start and stop the stream. It also shows the current track playing and what is currently queued.

![](http://f.cl.ly/items/3J2U1Z2x033R3p1I1J0b/play-item.png)

#### Features

* Streams shoutcast stream
* Displays currently playing track and queued tracks
* Media key support (Play/Pause)
* Star a song
* Download a song
* Download an album

### Play iOS

This is a streaming client for Play that runs on your iPhone/iPad. It supports background audio as well as the media keys when backgrounded.

![](http://f.cl.ly/items/1Z1W3P351q2V1m2v3n12/play-ios-iphone.png) ![](http://f.cl.ly/items/2Z0O09320f142y3x163q/play-ios-ipad.png)

#### Features

* Streams shoutcast stream
* Displays currently playing track
* Background audio
* Lock screen album art & play controls
* AirPlay (along with Bluetooth) streaming. Supports sending metadata and album art.

## Obtaining/Installing

### Play Item

You have a couple of choices for installing Play Item.

With Xcode installed, download or clone down this repository, open the project, set your target for `Play Item` and build it.

If you have no idea what I just said, just go the [Downloads](https://github.com/play/play-cocoa/downloads) section of this repository and download the most recent version of Play Item.


### Play iOS

Installing Play iOS is a little tricker. You must have an Apple developer account to get iOS applications on to your device.

If you have one, just download or clone down this repository, open the project, set your target for `Play iOS` and run it with your device plugged in and selected. Play iOS will install directly to your device and be ready to be used!


## Contributing

Fix something? Make something better?

Fork the project, create a topic branch, and send a Pull Request.


## Problem?

Create an [issue](https://github.com/play/play-cocoa/issues).

