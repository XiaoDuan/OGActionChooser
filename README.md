Purpose
---------

`OGActionChooser` is an iOS control that can be used as a replacement for `UIActionSheet` or `UIAlertView`. It displays an arbitrarily long list of button items, each having a title and image. The user can select an item or close the action chooser.
The items can optionally be disabled.

Sample Code
------------

    OGActionChooser* actionChooser = [OGActionChooser actionChooserWithDelegate:self];
    [actionChooser setTitle:@"Choose action"];
    [actionChooser setShouldDrawShadow:YES]; // default
    [actionChooser setButtonsWithArray:[NSArray arrayWithObjects:
                                         [OGActionButton buttonWithTitle:@"Action 1"
                                                               imageName:@"actionChooser_Button1.png" 
                                                                 enabled:YES],
                                         [OGActionButton buttonWithTitle:@"Action 2"
                                                               imageName:@"actionChooser_Button2.png" 
                                                                 enabled:YES],nil]];
    [actionChooser presentInView:self.view];


Delegate methods
-----------------

The caller (usually a view controller) should implement the following protocol:

    @protocol OGActionChooserDelegate <NSObject>
    @required
    - (void)actionChooser:(OGActionChooser*)ac buttonPressedWithIndex:(NSInteger)index;
    @optional
    - (void)actionChooserFinished:(OGActionChooser*)ac;
    @end

`actionChooser:buttonPressedWithIndex:` is called when a button item is selected. You can dismiss the action chooser with the `dismiss`-method here.

`actionChooserFinished:` is called, when the user closes the view or when you call `dismiss` on the action chooser.

