Android Model Agent
===================

Android Model Agent is a simple tool to help you generate one of Android's components, the ContentProvider.

Usage
-----
Edit the `data/model.xml` file for your model and run ant on the root of the project.
The files generated are placed in the gen folder.
You also need to match the `prefix` value with the same property in the `build.gradle` file.

To generate the files call `gradlew gen` or `gradle gen`.

The files generated are based on the open source [Google IO][2] project.
You can download the [`SelectionBuilder`][3] class from there.

Under the hood
--------------
This project uses [FreeMarker][1] for file generation.

 [1]:http://freemarker.sourceforge.net/fmpp.html
 [2]:https://code.google.com/p/iosched/
 [3]:https://code.google.com/p/iosched/source/browse/android/src/main/java/com/google/android/apps/iosched/util/SelectionBuilder.java