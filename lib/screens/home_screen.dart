import 'package:cuteemojigenerator/screens/emojicategory.dart';
import 'package:cuteemojigenerator/services/openaiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cuteemojigenerator/screens/ad_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  final TextEditingController _textController = TextEditingController();
  List<String> emojiCategorys = EmojiCategory().categorys;
  String seletedEmojiCategory = EmojiCategory().categorys[0];
  ApiService? apiService;
  OpenAIService? openAIService;
  String emojiResult = "";
  late final String apiKey;
  int? selectedIndex = 0;
  bool isItLoding = false;

  @override
  void initState() {
    super.initState();
    initializeApiService();
    _initGoogleMobileAds();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();

    // 텍스트 필드 값이 변경될 때 선택된 원을 초기화하는 리스너 추가
    _textController.addListener(() {
      if (_textController.text.isNotEmpty) {
        setState(() {
          selectedIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();

    super.dispose();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  Future<void> initializeApiService() async {
    await dotenv.load(fileName: ".env");
    apiKey = dotenv.env['GPTAPIKEY'].toString();
    setState(() {
      apiService = ApiService(apiKey);
      openAIService = OpenAIService(apiKey);
    });
  }

  Future<void> generateEmoji(String inputEmoji) async {
    setState(() {
      isItLoding = true;
    });
    if (openAIService == null) return;
    try {
      String result = await openAIService!.createModel(inputEmoji);
      print("result test : $result");
      setState(() {
        // emojiResult = utf8.decode(result.runes.toList());
        isItLoding = false;
        emojiResult = result;
      });
    } catch (error) {
      print("Error generating emoji: $error");
      setState(() {
        isItLoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("갑자기 분위기 랜덤 이모티콘")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.37,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
                itemCount: emojiCategorys.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedIndex == index; // 현재 원이 선택되었는지 여부
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        seletedEmojiCategory = emojiCategorys[index];
                        _textController.clear();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3.0)
                            : null, // 선택된 원에만 테두리 추가
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        emojiCategorys[index],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              onTap: () {
                setState(() {
                  selectedIndex = null; // 텍스트 필드 클릭 시 선택된 원 초기화
                });
              },
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    selectedIndex = null; // 텍스트 입력 시 선택된 원 초기화
                  }
                  seletedEmojiCategory = value;
                });
              },
              textAlign: TextAlign.center,
              controller: _textController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ex) 행복, 행복해',
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    apiService == null
                        ? null
                        : generateEmoji(seletedEmojiCategory);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50, // 연한 배경색
                    side: const BorderSide(
                        color: Colors.purple, width: 2.0), // 보더 색상과 두께
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 둥근 테두리
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24), // 여백
                  ),
                  child: const Text(
                    '생성',
                    style: TextStyle(
                      color: Colors.purple, // 텍스트 색상
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: emojiResult));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('복사되었습니다!')),
                      );
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.2,
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                        ),
                        child: isItLoding
                            ? const LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [Colors.black],
                                strokeWidth: 2,
                                pathBackgroundColor: Colors.black)
                            : Text(
                                emojiResult,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'NotoSans',
                                ),
                                textDirection: TextDirection.ltr,
                              )),
                  ),
                ],
              ),
            ),
            if (_bannerAd != null)
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
