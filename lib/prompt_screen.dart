import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PromptScreen extends StatefulWidget {
  final VoidCallback showHomeScreen;
  const PromptScreen({super.key, required this.showHomeScreen});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  String currentTranscript = "";
  String transcriptText = "";
  String errorMessage = "";
  final List<String> genres = [
    'Jazz',
    'Rock',
    'Amapiano',
    'R&B',
    'Latin',
    'Hip-Hop',
    'Hip-Life',
    'Reggae',
    'Gospel',
    'Afrobeat',
    'Blues',
    'Country',
    'Punk',
    'Pop',
  ];

  final Set<String> _selectedGenres = {};
  List<Map<String, String>> _playlist = [];
  bool _isLoading = false;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;

  // Khai báo SpeechToText
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false; // Để theo dõi trạng thái nghe

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _audioRecorder.openRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await requestMicrophonePermission();
      status = await Permission
          .microphone.status; // Kiểm tra lại trạng thái sau khi yêu cầu
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Microphone permission is required."),
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    if (_audioRecorder.isStopped) {
      print("Bắt đầu ghi âm...");

      Directory downloadDir = Directory('/storage/emulated/0/Download');
      String audioFilePath = '${downloadDir.path}/audio.wav';

      await _audioRecorder.startRecorder(
        toFile: audioFilePath,
        codec: Codec.pcm16WAV,
        numChannels: 1,
      );
      setState(() {
        _isRecording = true;
        errorMessage = ""; // Reset lỗi khi bắt đầu ghi âm
      });
    } else {
      print("Đang ghi âm...");
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      await _speechToText.stop();
      // Thông báo cho người dùng rằng nghe đã dừng
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      debugPrint("Dừng ghi âm...");
      String? audioFilePath = await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (audioFilePath != null && audioFilePath.isNotEmpty) {
        debugPrint('Đã nhận dữ liệu âm thanh từ: $audioFilePath');

        // Gọi hàm sendAudioToShazam
        await sendAudioToShazam(audioFilePath);
      } else {
        debugPrint("Không có dữ liệu âm thanh để gửi.");
      }
    } else {
      debugPrint("Không có gì để dừng, không đang ghi âm.");
    }
  }
  // sendAudioToWitAI

  Future<void> sendAudioToWitAI(String audioFilePath) async {
    try {
      Uint8List audioData = await File(audioFilePath).readAsBytes();

      var request = http.Request(
        'POST',
        Uri.parse('https://api.wit.ai/speech?v=20240304'),
      );

      request.headers['Authorization'] = 'Bearer ${dotenv.env['WIT_AI_TOKEN']}';
      request.headers['Content-Type'] = 'audio/wav';

      request.bodyBytes = audioData;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print("Phản hồi từ API: $responseData");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(responseData);
          if (data['text'] != null && data['text'].isNotEmpty) {
            print("Nội dung nhận diện được: ${data['text']}");
            setState(() {
              transcriptText = data['text'];
              errorMessage = "";
            });
          } else {
            print("Không có nội dung nhận diện được.");
            setState(() {
              transcriptText =
                  "Không nhận diện được âm thanh. Vui lòng nói rõ ràng hơn.";
              errorMessage = "";
            });
          }
        } catch (jsonError) {
          print("Lỗi khi phân tích JSON: $jsonError");
          setState(() {
            transcriptText = "";
            errorMessage = "Có lỗi xảy ra khi phân tích phản hồi từ API.";
          });
        }
      } else {
        final errorResponse = await response.stream.bytesToString();
        print("Thông báo lỗi từ API: $errorResponse");
        setState(() {
          transcriptText = "";
          errorMessage = "Đã xảy ra lỗi: ${response.statusCode}.";
        });
      }
    } catch (e) {
      print("Đã xảy ra lỗi: $e");
      setState(() {
        transcriptText = "";
        errorMessage = "Đã xảy ra lỗi khi gửi âm thanh. Vui lòng thử lại.";
      });
    }
  }

  // sendAudioToShazam
  Future<void> sendAudioToShazam(String audioFilePath) async {
    try {
      Uint8List audioData = await File(audioFilePath).readAsBytes();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://soundcloud-api3.p.rapidapi.com/search/track?query=post%20malone&limit=5&after=0'),
      );

      request.headers['x-rapidapi-host'] = 'soundcloud-api3.p.rapidapi.com';
      request.headers['x-rapidapi-key'] = 'RAPIDAPI_KEY';

      request.files.add(http.MultipartFile.fromBytes(
        'upload_file',
        audioData,
        filename: 'audio.wav',
      ));

      // Gửi yêu cầu và nhận phản hồi
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      print("Phản hồi từ Music API: $responseData");

      if (response.statusCode == 200) {
        // Xử lý dữ liệu phản hồi từ Shazam
        final data = json.decode(responseData);
        if (data['track'] != null) {
          final track = data['track'];
          print(
              "Tên bài hát: ${track['title']}, Nghệ sĩ: ${track['subtitle']}");
          setState(() {
            transcriptText =
                "Tên bài hát: ${track['title']}, Nghệ sĩ: ${track['subtitle']}";
            errorMessage = "";
          });
        } else {
          print("Không tìm thấy bài hát.");
          setState(() {
            transcriptText = "Không tìm thấy bài hát.";
            errorMessage = "";
          });
        }
      } else {
        print("Lỗi từ Soundcloud: ${response.statusCode}");
        setState(() {
          transcriptText = "";
          errorMessage = "Đã xảy ra lỗi khi tìm kiếm bài hát.";
        });
      }
    } catch (e) {
      print("Lỗi khi gửi âm thanh tới Shazam: $e");
      setState(() {
        transcriptText = "";
        errorMessage = "Đã xảy ra lỗi khi gửi âm thanh. Vui lòng thử lại.";
      });
    }
  }

  void _onGenreTap(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  Future<void> _submitSelections() async {
    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one genre"),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // Thực hiện logic tìm kiếm playlist tại đây

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 73, 13, 13),
              Color.fromARGB(255, 105, 13, 13),
              Color.fromARGB(255, 37, 3, 3),
              Color.fromARGB(255, 26, 2, 2),
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Genres',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: genres.map((genre) {
                            bool isSelected = _selectedGenres.contains(genre);
                            return GestureDetector(
                              onTap: () => _onGenreTap(genre),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: isSelected
                                      ? Colors.deepOrange
                                      : Colors.white.withOpacity(0.2),
                                ),
                                child: Text(
                                  genre,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transcription',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transcriptText.isNotEmpty ? transcriptText : "",
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF).withOpacity(0.8),
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorMessage,
                            style: GoogleFonts.inter(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          onLongPress: _startRecording,
                          onLongPressUp: _stopRecording,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording
                                  ? Colors.red
                                  : Color.fromARGB(255, 194, 64, 55),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      _isLoading
                          ? Expanded(
                              // Sử dụng Expanded để nút tìm kiếm có thể chiếm toàn bộ chiều rộng
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _submitSelections,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 194, 64, 55),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 40,
                                    ),
                                    minimumSize: Size(double.infinity,
                                        50), // Đặt chiều rộng tối thiểu cho nút
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Tìm kiếm',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 80,
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
