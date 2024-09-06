import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/queue.dart';
import 'package:mitek_video_call_sdk/models/user.dart';
import 'package:mitek_video_call_sdk/view/page/calling_page.dart';
import 'package:mitek_video_call_sdk_eample/app_dropdown.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MITEK VideoCall Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
  double space = 18;

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
        title: const Text(
          "MITEK Video Call SDK Demo",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.cyan, Colors.blue],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: isAuthenticating
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    userSection(),
                    infoCallSection(),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MTCallingPage(
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
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.video_call,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget userSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label("Name", true),
        tF(_nameCtrl, "Name"),
        SizedBox(height: space),
        label("Phone", false),
        tF(_phoneCtrl, "Phone"),
        SizedBox(height: space),
        label("Email", false),
        tF(_emailCtrl, "Email"),
        SizedBox(height: space),
      ],
    );
  }

  Widget label(String label, [bool isRequired = false]) {
    const double fontSize = 16;
    return isRequired
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                ),
              ),
              const Text(
                "*",
                style: TextStyle(
                  color: Colors.red,
                ),
              )
            ],
          )
        : Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: fontSize,
            ),
          );
  }

  Widget infoCallSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label("Queue"),
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
        label("Video input"),
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
        label("Audio input"),
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
