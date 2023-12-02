## DreamInGrid 

This is a fork of [n1ckfg's Processing Shader Examples](https://github.com/genekogan/Processing-Shader-Examples/), adapted into a VJing app using [Minim](https://code.compartmental.net/minim/)'s beat analysis and audio buffer and an extension of the original P5Control shader switching backend.
At present, it only uses the `ColorShaders` folder from the orginal repo. 

The app can run itself, using randomised values, or can be run manually as a VJ app, using the following hotkeys:

- R Key: Toggles "Random" mode. The app will run itself while random mode is enabled.
- A/D Keys: A/D decrement/increment the index of the currently playing shader, respectively. 
- Number Keys 0-9: These manually set the index of the currently playing shader (there are 10 shaders at time of writing).
- Esc: when running one of the release executables in full screen mode, this will kill the app. 

The app will react to whatever audio is being input into Windows' default audio device for *recording*. You can use something like [VB Virtual Audio Cable](https://vb-audio.com/Cable/) to get more control over this when not using a hardware line-in. 

Requires the [ControlP5 library](http://www.sojamo.de/libraries/controlP5/) and the [Minim library](https://code.compartmental.net/minim/).
