Android Model Agent
===================

Android Model Agent is a simple tool to help you generate one of Android's components, the ContentProvider.

Usage
-----
Edit the `data/model.xml` file for your model and run `gradlew gen` or `gradle gen` on the root of the project.
The files generated are placed in the gen folder.

Under the hood
--------------
This project uses [FreeMarker][1] for file generation.

 [1]:http://freemarker.sourceforge.net/fmpp.html