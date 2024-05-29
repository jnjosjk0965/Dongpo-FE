import 'package:dongpo_test/screens/main/main_03/main_03.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'main_02.dart';
import 'package:dongpo_test/api_key.dart';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// 지도 초기화하기
Future<void> reset_map() async {
  // splash 화면 종료
  FlutterNativeSplash.remove();

  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: naverApiKey, // 클라이언트 ID 설정
      onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"));
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  //애니메이션 컨트롤러를 사용하는 위젯에 필요한 Ticker를 제공
  late NaverMapController _mapController;
  String _currentAddress = "";
  bool _showReSearchButton = false;
  late AnimationController _controller; // 애니메이션 컨트롤러 선언
  late Animation<Offset> _offsetAnimation; // 슬라이더 애니메이션 선언
  late Animation<double> _buttonAnimation; // 버튼 애니메이션 선언
  late Animation<double> _locationBtn;

  @override
  //초기화
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (300ms 동안 애니메이션 실행)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 슬라이더 애니메이션 설정 (화면의 60% 지점에서 시작하여 원래 위치로)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 버튼 애니메이션 설정 (초기 위치는 100, 최종 위치는 300)
    _buttonAnimation = Tween<double>(
      begin: 45.0,
      end: 165.0, // 100 + 200 (컨테이너 높이)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    //내 위치 버튼 애니메이션 설정
    _locationBtn = Tween<double>(
      begin: 85.0,
      end: 210.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }

  // 슬라이더 토글 함수
  void _toggleBottomSheet() {
    setState(() {
      if (_controller.isDismissed) {
        _controller.forward(); // 애니메이션 시작
      } else {
        _controller.reverse(); // 애니메이션 되돌리기
      }
    });
  }

  // 화면관련 여기서부터 보면 됌

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == "위치 권한이 허가 되었습니다.") {
            return Stack(
              children: [
                //네이버 지도 시작
                NaverMap(
                  onMapReady:
                      //마커 생성
                      (controller) async {
                    _onMapReady(controller);
                    log("onMapReady", name: "onMapReady");
                    final NLatLng test = NLatLng(
                        37.49993604717163, 126.86768245932946); //테스트 위도 경도

                    NMarker marker = NMarker(
                      id: "test_Maker",
                      position: test,
                    );

                    // 커스텀 마커를 비동기로 로드하여 메인 스레드의 부담을 줄입니다.
                    var customMarker = await NOverlayImage.fromAssetImage(
                        "assets/images/rakoon.png");

                    var clickedMaker = await NOverlayImage.fromAssetImage(
                        "assets/images/profile_img1.jpg");
                    marker.setIcon(customMarker);

                    marker.setOnTapListener((overlay) {
                      //마커 아이콘 바뀌기
                      marker.setIcon(clickedMaker);
                      controller.addOverlay(marker);

                      //마커 있는 위치로 화면 전환
                      //하단에 Container 올라와서 가게상세 페이지 연동
                      logger.d('마커 동작');
                    });

                    // 마커 크기 조절을 통해 성능 최적화
                    var defaultMarkerSize = Size(40, 50);
                    marker.setSize(defaultMarkerSize);

                    // 마커 표시
                    controller.addOverlay(marker);
                  },

                  //렉 유발 하는 듯 setstate로 인한 지도 재호출
                  // 카메라 변경 이벤트 시 상태 업데이트 최소화
                  onCameraChange: (reason, animated) {
                    if (!_showReSearchButton) {
                      setState(() {
                        _showReSearchButton = true;
                      });
                    }
                  },

                  options: NaverMapViewOptions(
                    locationButtonEnable: false, // 위치 버튼 표시 여부 설정
                    minZoom: 15, //쵀대 줄일 수 있는 크기?
                    maxZoom: 18, //최대 당길 수 있는 크기
                    initialCameraPosition: NCameraPosition(
                      //첫 로딩시 카메라 포지션 지정
                      target: NLatLng(37.49993604717163, 126.86768245932946),
                      zoom: 16, bearing: 0,
                    ),
                  ),
                ),
                //네이버 맵 끝
                Positioned(
                  top: 65.0,
                  left: 16.0,
                  right: 16.0,
                  //상단 검색바
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SearchPage();
                      }));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      //검색바 안에 주소
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 8.0),
                          Text(
                            _currentAddress,
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[400]),
                          ),
                          Spacer(),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _offsetAnimation, // 슬라이더 애니메이션 적용
                    child: Container(
                      padding: EdgeInsets.all(25),
                      height: 200, // 튀어나오는 부분을 포함한 전체 높이
                      width: 500,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'A (구로구 고척동)',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              height: 90,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (BuildContext ctx, int idx) {
                                    return Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return StoreInfo(); //터치하면 해당 가게 상세보기로
                                            }));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 20, 20, 20),
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            height: 100,
                                            child: Row(
                                              children: [
                                                //CircleAvatar 컨테이너
                                                Container(
                                                  height: 30,
                                                  width: 40,
                                                  child: CircleAvatar(
                                                    minRadius: 15,
                                                    backgroundImage: AssetImage(
                                                        'assets/images/rakoon.png'),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'A(고척 포장마차 1)',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          size: 13,
                                                          color:
                                                              Color(0xffF15A2B),
                                                        ),
                                                        Text(
                                                          'A 영업 가능성 높아요!',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              fontSize: 10),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ]),
                    ),
                  ),
                ),

                //위치 재검색 버튼
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  top: _showReSearchButton ? 110.0 : -40.0,
                  left: MediaQuery.of(context).size.width / 3.5,
                  right: MediaQuery.of(context).size.width / 3.5,
                  child: GestureDetector(
                    onTap: () async {
                      await _reSearchCurrentLocation();
                      setState(() {
                        _showReSearchButton = false;
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Color(0xffF15A2B),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "해당 위치로 재검색",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          SizedBox(width: 8.0),
                          Icon(Icons.refresh, color: Colors.white, size: 16.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // 왼쪽 하단 내 위치 재검색 버튼
                AnimatedBuilder(
                    animation: _locationBtn,
                    builder: (context, child) {
                      return Positioned(
                        bottom: _locationBtn.value,
                        left: 16.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                              foregroundColor: Colors.blue,
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white)),
                          onPressed: _moveToCurrentLocation,
                          child: Icon(Icons.my_location),
                        ),
                      );
                    }),

                // 슬라이더와 함께 올라오는 버튼
                AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: _buttonAnimation.value, // 애니메이션 값에 따라 위치 설정
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IconButton(
                            onPressed: () {
                              _toggleBottomSheet();
                              //현재 위치 위도경도 기준으로해서 리스트 받아온거 기본정보 띄우는 함수 만들어야함
                              //ex)) 게시판의 제목
                            },
                            icon: Icon(Icons.menu)),
                      ),
                    );
                  },
                ),
              ],
            );
          }
          // 권한이 거절되었을 시 알림 표시 후 앱 종료
          else {
            _showPermissionDenied();
            return Container();
          }
        },
      ),
    );
  }

  // 함수 정의

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
  }

  Future<void> _moveToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _mapController.updateCamera(
      NCameraUpdate.fromCameraPosition(
        NCameraPosition(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 14,
        ),
      ),
    );
    _updateAddress(position.latitude, position.longitude);
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.locality} ' '${place.street} ';
      });
    } catch (e) {
      setState(() {
        _currentAddress = '주소를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _reSearchCurrentLocation() async {
    final cameraPosition = await _mapController.getCameraPosition();
    final latitude = cameraPosition.target.latitude;
    final longitude = cameraPosition.target.longitude;
    print('현재 지도의 중앙 좌표: 위도 $latitude, 경도 $longitude');
  }

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    return '위치 권한이 허가 되었습니다.';
  }

  // 위치 권한 거절 시 알림 표시 후 앱 종료
  void _showPermissionDenied() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('위치 권한 필요!'),
            content: Text('이 앱은 위치 권한이 필요합니다. 권한을 허용해주세요.'),
            actions: <Widget>[
              TextButton(
                child: Text('앱 종료'),
                onPressed: () {
                  SystemNavigator.pop(); // 앱 종료
                  print('앱 종료');
                },
              ),
              TextButton(
                  onPressed: () {
                    print('설정으로 이동');
                    openAppSettings();
                  },
                  child: Text("설정으로 이동"))
            ],
          );
        },
      );
    });
  }

  //마커를 지도에 띄우는 함수
  // Future<void> showMarker() async {
  //   for (int i in phoChaList) {
  //     NMarker marker = NMarker(
  //         id: "marker_$i",
  //         position: NLatLng(phoChaList[i].latitude, phoChaList[i].longitude));
  //     _mapController.addOverlay(marker);
  //   }
  // }
}
