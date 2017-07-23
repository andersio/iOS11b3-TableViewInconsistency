rdar://33477509

Area:
UIKit

Summary:
It appears that the UITableView internal algorithm to compute changes has changed, and it now handles section deletion incorrectly. `NSInternalInconsistencyException` is raised even for a very simple case of section deletion.

A workaround was found, but it works only for a small number of sections.

Steps to Reproduce:
A sample project is attached with the bug report. It has been tested with Xcode 8.3.3 + iOS 10.3.1, and Xcode 9.0 beta 3 + iOS 11 beta 3.

# Using the project

1. Build and launch the app on iOS 11 beta 3.
2. Swipe to delete any rows — except the last one — in the table view, and observe that `NSInternalInconsistencyException` is raised.
3. Relaunch the app, and turn on the workaround using the UISwitch on the navigation bar.
4. Swipe to delete again, and observe that `NSInternalInconsistencyException` is raised. Note that if the number of sections is reduced, the workaround actually gets to work.
5. Repeat (1) to (4) on iOS 10.3.1, and observe that no exception is ever raised.

# Reproducing manually

1. Create a UITableView with two sections.
2. Delete the section at index 0 using `deleteSections(_:with:)`.
3. Observe that `NSInternalInconsistencyException` is raised when running on iOS 11 beta 3.
1. Redo (1) to (3) on iOS 10.3.1, and observe that it is functional.

# On the `NSInternalInconsistencyException`.
Given a section deletion at N, the exception tells that section at N has 1 row before the update and 1 row after the update. This is correct. But on top of that, the exception also tells that section N has **1 row deletion** applied by the update. This seems to indicate a flawed algorithm, since the post-deletion section at N (which is at N+1 before the deletion) should actually be untouched.

Expected Results:
iOS 10.3 behaviour.

Observed Results:
`NSInternalInconsistencyException`.

Version:
Xcode 8.3.3
iOS 10.3.1 simulator
Xcode 9 beta 3
iOS 11.0 beta 3 simulator
