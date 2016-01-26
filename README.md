# prkng-ios GitHub repo

Git Repo Usage Guidelines
--------------------

1. Use issues to track a discussion/question/bug/enhancement/minor feature
  - When creating an issue, give you best guess for bug/enhancement, milestone, and other labels if you deem them appropriate
  -  __Assign an issue _only_ if the work needs to be completed now/it should be in progress__
2. Use milestones to track large features OR versions, and issues associated to that milestone to break the feature up into steps
3. Branches should _generally_ be linked to a milestone, and (obviously) can be unstable
4. Master must always be deployable, but work can be done straight to it provided that it doesn't break everything and has been reasonably tested
5. Usage guidelines subject to change :)

prkng
=====

The prkng iOS App
-----------------


How to Build and Run
--------------------

In addition to adding certain libraries manually, we use Cocoapods as a dependency manager. The easiest way to install it is to simply open up the terminal and...

    sudo gem install cocoapods
    pod setup

...then to install the actual dependencies all you have to do is cd to the directory (terminal > cd > drag the finder folder to the window and it will automatically populate the path). From the directory just do...

    pod install

Now, all you have to do is launch the workspace file. NOT the project file. Happy coding :)

-Ant


Directory Structure Cleanup
--------------------
Xcode can be a little loose about where it puts things by default. 
You can re-organize the local filesystem to match Xcode's Project Navigator view with a tool called Synx. 

https://github.com/venmo/synx

It may be a good idea to run this tool every few months to make sure nothing is in a weird place. 

-Ant
