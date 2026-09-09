package com.an.an

import com.ryanheise.audioservice.AudioServiceActivity

// Extends AudioServiceActivity (not FlutterActivity) so just_audio_background
// can bind its media-browser service to this activity for lock-screen /
// notification playback controls.
class MainActivity : AudioServiceActivity()
