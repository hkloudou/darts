# flutter_wise_markdown

A new Flutter package project.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## init
``` dart
WiseLaunchAdapter.onUrlFetchRequest= (cancelToken)=>dio....
```
### urlLauch tip
Link: https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher
#### iOS
Add any URL schemes passed to canLaunch as LSApplicationQueriesSchemes entries in your Info.plist file.

#### Example:
```
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
</array>
See -[UIApplication canOpenURL:] for more details.
```