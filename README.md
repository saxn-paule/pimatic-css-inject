# Configuration
There is no special configuration needed. Just create a CssInjectDevice and place it somewhere in the GUI. It doesn't matter where.
Create a rule that contains a CSS variable, a CSS selctor and an attribute that corresponds to the variable.

e.g.
```
when dummy-switch is turned on
then set css "color" of "#my-favorite-element" to "green"
```


# Beware
This plugin is in an early alpha stadium and you use it on your own risk.
I'm not responsible for any possible damages that occur on your health, hard- or software.

# License
MIT
