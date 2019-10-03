This workshop is implemented using [Homeroom](https://github.com/openshift-homeroom).

Homeroom provides an interactive training environment you can use in your web browser, without needing to install anything on your local machine.

The Homeroom dashboard provides you access to the workshop content and one or more terminals. The interactive shells provided via the terminals are hosted in a container running inside of a Kubernetes cluster, using OpenShift, Red Hat's distribution of Kubernetes.

As you work through the workshop content you will encounter commands that you need to run in the terminals. These will appear as:

```execute
echo 'Hi there!'
```

Where a command appears with the symbol <span class="fas fa-play-circle"></span> to the right side of the command, you do not need to type the command into the terminal yourself. Instead, click anywhere on the command and it will be run automatically in the terminal for you.

Try clicking on the above command if you haven't done so already.

Usually the command will be run in the terminal at the top, but in some cases it will be run in the bottom terminal. You don't have to worry about which, the command when clicked will be run where it needs to be.

Try clicking the command below and it should go the terminal at the bottom.

```execute-2
echo 'And here!'
```

If at any time a glitch occurs and the workshop content doesn't display properly because of a network issue, and so an error is displayed, or it shows as a white page, select the dropdown hamburger menu top right in the banner above the terminals and select "Reload Workshop". That menu item will reload just the workshop content and leave you on the same page.

**Do not use the ability of the browser to reload the whole browser page as you will loose where you were up to in the workshop content. Also do not use the "Restart Session" menu item unless specifically directed to as you will loose all your work.**

Similarly, if the terminals stop working or show as closed, select "Reload Terminal" from the dropdown hamburger menu.

If you have any issues which using the reload menu items don't solve, ask the workshop instructor.
