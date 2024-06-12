import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dongpo_test/main.dart';
import 'package:dongpo_test/screens/login/kakao_naver_login.dart';
import 'package:dongpo_test/screens/login/login.dart';
import 'package:dongpo_test/screens/login/login_view_model.dart';
import 'package:image_picker/image_picker.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final loginViewModel = LoginViewModel(KakaoNaverLogin());
  static final storage = FlutterSecureStorage();
  bool isLogouted = false;

  // 프로필 사진 수정 관련
  final picker = ImagePicker();
  XFile? image;

  //버튼 활성화 비활성화를 위한 value값
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 없애기
        centerTitle: true,
        title: Text(
          "마이 페이지",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // 스크롤
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 48, left: 24, right: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 프로필 사진
                  CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        AssetImage('assets/images/profile_img1.jpg'),
                  ),
                  SizedBox(width: 16), // 간격 조정
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                      children: [
                        // 칭호
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5E0D9),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Color(0xFFF5E0D9), // 테두리 색상
                            ),
                          ),
                          child: Text(
                            "막 개장한 포장마차",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF15A2B),
                            ),
                          ),
                        ),
                        SizedBox(height: 8), // 간격 조정
                        // 닉네임
                        Text(
                          "도도한 고양이",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // 간격 조정
            Container(
              height: 44,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24),
              // 프로필 편집 버튼
              child: OutlinedButton(
                onPressed: () {
                  showEditProfileBottomSheet(context);
                },
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ))),
                child: Text(
                  '프로필 편집',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF767676),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24), // 간격 조정
            // 등록한 가게, 칭호, 선물함
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 등록한 가게
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF767676),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '등록한 가게',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // 칭호
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF767676),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '칭호',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // 선물함
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF767676),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '선물함',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF767676),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4F4),
                ),
              ),
            ),
            // 내 칭호, 내가 쓴 리뷰, 북마크한 가게, 선물함
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                title: Text(
                  '내 칭호',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF767676)),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // 내 칭호 버튼이 클릭되었을 때의 액션
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                title: Text(
                  '내가 쓴 리뷰',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF767676)),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // 내가 쓴 리뷰 버튼이 클릭되었을 때의 액션
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                title: Text(
                  '북마크한 가게',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF767676)),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // 북마크한 가게 버튼이 클릭되었을 때의 액션
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                title: Text(
                  '선물함',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF767676)),
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // 선물함 버튼이 클릭되었을 때의 액션
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              color: Color(0xFFF4F4F4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      String? loginPlatform =
                          await storage.read(key: 'loginPlatform');
                      if (loginPlatform == null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false, // 모든 이전 페이지 제거
                        );
                      }
                      isLogouted = await loginViewModel.logout(loginPlatform);
                      if (isLogouted) {
                        // FlutterSecureStorage에 있는 token 삭제
                        await storage.delete(key: 'accessToken');
                        await storage.delete(key: 'refreshToken');
                        await storage.delete(key: 'loginPlatform');
                        Map<String, String> allData = await storage.readAll();
                        logger.d("secure storage delete read : ${allData}");
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false, // 모든 이전 페이지 제거
                        );
                      }
                    },
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      String? loginPlatform =
                          await storage.read(key: 'loginPlatform');
                      if (loginPlatform == null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false, // 모든 이전 페이지 제거
                        );
                      }
                      isLogouted = await loginViewModel.logout(loginPlatform);
                      if (isLogouted) {
                        // FlutterSecureStorage에 있는 token 삭제
                        await storage.delete(key: 'accessToken');
                        await storage.delete(key: 'refreshToken');
                        await storage.delete(key: 'loginPlatform');
                        Map<String, String> allData = await storage.readAll();
                        logger.d("secure storage delete read : ${allData}");
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false, // 모든 이전 페이지 제거
                        );
                      }
                    },
                    child: Text(
                      '탈퇴',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xFF767676),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditProfileBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // 현재 화면 높이
    final bottomSheetHeight = screenHeight * 0.45; // 화면 높이의 50%

    // TextEditingController를 사용하여 초기값 설정
    final TextEditingController nicknameController =
        TextEditingController(text: "사용자1");
    String nickname = nicknameController.text;

    showModalBottomSheet(
      isScrollControlled: true, // 키보드가 올라올 때 바텀시트가 따라 올라감
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); //
                },
                child: Container(
                  height: bottomSheetHeight,
                  width: double.infinity,
                  margin: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "프로필 편집",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  CupertinoIcons.xmark,
                                  size: 24,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final XFile? pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  image = pickedFile;
                                  value = 1;
                                  logger.d("image path : ${image!.path}");
                                  logger.d("image value : ${value}");
                                });
                              }
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40, // 80 / 2
                                  backgroundImage: image != null
                                      ? FileImage(File(image!.path))
                                      : AssetImage(
                                              'assets/images/profile_img1.jpg')
                                          as ImageProvider,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Color(0xFF767676),
                                      size: 24,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: TextField(
                              controller:
                                  nicknameController, // TextEditingController를 연결
                              onChanged: (text) {
                                setState(() {
                                  nickname = text;
                                  value = 1;
                                  logger.d("image value : ${value}");
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "닉네임",
                                hintText: '7글자까지 입력 가능해요',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF767676),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF767676),
                                    )),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFF767676),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  splashFactory: (value == 0)
                                      ? NoSplash.splashFactory
                                      : InkSplash.splashFactory,
                                  // 수정이 있을 경우 버튼 활성화
                                  backgroundColor: (value == 1)
                                      ? Color(0xffF15A2B)
                                      : Color(0xFFF4F4F4),
                                  minimumSize: Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12)))),
                              onPressed: () {
                                // 프로필 수정 로직 구현
                                (value == 0) ? null : logger.d("저장 완");
                              },
                              child: Text(
                                '저장',
                                style: TextStyle(
                                    color: (value == 1)
                                        ? Colors.white
                                        : Color(0xFF767676)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
