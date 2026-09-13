package com.an.an

import com.ryanheise.audioservice.AudioServiceFragmentActivity

// Extends AudioServiceFragmentActivity (not FlutterActivity):
//  - audio_service / just_audio_background binds its media-browser service to
//    this activity for lock-screen / notification playback controls, and
//  - it is a FlutterFragmentActivity, which local_auth needs for the Android
//    biometric prompt (Khoá bằng Face ID / vân tay).
class MainActivity : AudioServiceFragmentActivity()
