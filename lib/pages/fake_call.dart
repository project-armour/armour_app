import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key, this.ring = false});

  final bool ring;

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool isMuted = false;
  bool speakerMode = false;
  bool ringerMode = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.ring) {
      setState(() {
        ringerMode = true;
        speakerMode = true;
      });
      playSound('assets/sounds/ringtone.aac', loop: true);
    } else {
      setState(() {
        speakerMode = false;
      });
      playSound('assets/sounds/fakecall-audio.aac');
    }
  }

  void playSound(String soundPath, {bool loop = false}) async {
    final session = await AudioSession.instance;

    if (speakerMode) {
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
        ),
      );
    } else {
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
        ),
      );
    }
    try {
      await player.setAsset(soundPath);
    } catch (e) {
      print(e);
    }
    if (loop) {
      await player.setLoopMode(LoopMode.all);
    } else {
      await player.setLoopMode(LoopMode.off);
    }
    await player.play();
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/call-bg.png', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 120,
                bottom: 100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300?img=5',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        ringerMode
                            ? [
                              _CallActionButton(
                                icon: Icons.call,
                                label: 'Answer',
                                color: Colors.green,
                                onPressed: () {
                                  player.stop();
                                  setState(() {
                                    ringerMode = false;
                                    speakerMode = false;
                                    playSound(
                                      'assets/sounds/fakecall-audio.aac',
                                    );
                                  });
                                },
                              ),
                              _CallActionButton(
                                icon: Icons.call_end,
                                label: 'Decline',
                                color: Colors.red,
                                onPressed: () {
                                  player.stop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ]
                            : [
                              _CallActionButton(
                                icon: Icons.mic_off,
                                label: 'Mute',
                                color:
                                    isMuted
                                        ? ColorScheme.of(context).primary
                                        : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    isMuted = !isMuted;
                                  });
                                },
                              ),
                              _CallActionButton(
                                icon: LucideIcons.volume2,
                                label: 'Speaker',
                                color:
                                    speakerMode
                                        ? ColorScheme.of(context).primary
                                        : Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    speakerMode = !speakerMode;
                                    if (speakerMode) {
                                      player.setAndroidAudioAttributes(
                                        const AndroidAudioAttributes(
                                          usage: AndroidAudioUsage.media,
                                        ),
                                      );
                                    } else {
                                      player.setAndroidAudioAttributes(
                                        const AndroidAudioAttributes(
                                          usage:
                                              AndroidAudioUsage
                                                  .voiceCommunication,
                                        ),
                                      );
                                    }
                                  });
                                },
                              ),
                              _CallActionButton(
                                icon: Icons.call_end,
                                label: 'End',
                                color: Colors.red,
                                onPressed: () {
                                  player.stop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            decoration: ShapeDecoration(
              color: ColorScheme.of(
                context,
              ).surfaceContainerLow.withValues(alpha: 0.4),
              shape: const CircleBorder(),
            ),
            child: IconButton(
              padding: EdgeInsets.all(12),
              icon: Icon(icon, color: color),
              iconSize: 32,
              onPressed: onPressed,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextTheme.of(context).bodySmall),
      ],
    );
  }
}
