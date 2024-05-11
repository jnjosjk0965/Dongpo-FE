import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaverMapApp extends StatefulWidget {
  const NaverMapApp({super.key});

  @override
  State<NaverMapApp> createState() => NaverMapAppState();
}

class NaverMapAppState extends State<NaverMapApp> {
  @override
  Widget build(BuildContext context) {
    final Completer<NaverMapController> mapControllerCompleter = Completer();

    return Scaffold(

      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              indoorEnable: true, // 실내 맵 사용 가능 여부 설정
              locationButtonEnable: false, // 위치 버튼 표시 여부 설정
              consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
            ),
            onMapReady: (controller) async {
              // 지도 준비 완료 시 호출되는 콜백 함수
              mapControllerCompleter.complete(controller); // Completer에 지도 컨트롤러 완료 신호 전송
              log("onMapReady", name: "onMapReady");
            },
          ),
        ],
      ),
    );
  }
}