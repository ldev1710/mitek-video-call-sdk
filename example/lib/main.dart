import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk_eample/app_dropdown.dart';
import 'package:mitek_video_call_sdk_eample/pages/calling_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isAuthenticating = true;
  late List<MTQueue> queues;
  late List<MediaDevice> audioInputs;
  late List<MediaDevice> videoInputs;
  MTQueue? queueSelected;
  MediaDevice? audioInputSelected;
  MediaDevice? videoInputSelected;
  double space = 24;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameCtrl.text = "Dien test sdk";
    authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: GestureDetector(
          onTap: () {
            MTVideoCallPlugin.instance.disconnectVideoCall();
          },
          child: Text(widget.title),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: isAuthenticating
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    tF(_nameCtrl, "Name"),
                    SizedBox(height: space),
                    tF(_phoneCtrl, "Phone"),
                    SizedBox(height: space),
                    tF(_emailCtrl, "Email"),
                    SizedBox(height: space),
                    AppDropdown(
                      height: 65,
                      dropdownMenuItemList: queues
                          .map(
                            (e) => DropdownMenuItem<MTQueue>(
                              value: e,
                              child: Text(e.queueName),
                            ),
                          )
                          .toList(),
                      onChanged: (queue) {
                        queueSelected = queue;
                      },
                      hint: "Queue",
                      value: queueSelected,
                    ),
                    SizedBox(height: space),
                    AppDropdown(
                      height: 65,
                      dropdownMenuItemList: videoInputs
                          .map(
                            (e) => DropdownMenuItem<MediaDevice>(
                              value: e,
                              child: Text(e.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        videoInputSelected = value;
                      },
                      hint: "Video input",
                      value: videoInputSelected,
                    ),
                    SizedBox(height: space),
                    AppDropdown(
                      height: 65,
                      dropdownMenuItemList: audioInputs
                          .map(
                            (e) => DropdownMenuItem<MediaDevice>(
                              value: e,
                              child: Text(e.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        audioInputSelected = value;
                      },
                      hint: "Audio input",
                      value: audioInputSelected,
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallingPage(
                user: MTUser(
                  name: _nameCtrl.text,
                  email: _emailCtrl.text,
                  phone: _phoneCtrl.text,
                ),
                queue: queueSelected ?? queues.first,
                device: videoInputSelected ?? videoInputs.first,
              ),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.video_call),
      ),
    );
  }

  Future<void> authenticate() async {
    final bool =
        await MTVideoCallPlugin.instance.authenticate(apiKey: '60c05e8a35853f5f3ac2ab20c70eecce');
    queues = await MTVideoCallPlugin.instance.getQueues();
    audioInputs = MTVideoCallPlugin.instance.getDeviceAudioInput();
    videoInputs = MTVideoCallPlugin.instance.getDeviceVideoInput();
    setState(() {
      isAuthenticating = false;
    });
  }

  Widget tF(TextEditingController controller, String hint) {
    return Container(
      width: double.infinity,
      height: 65,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
