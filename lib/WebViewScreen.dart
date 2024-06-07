import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_overlay/loading_overlay.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;
  final CookieManager cookieManager = CookieManager.instance();
  var initialURL='https://app.kool.lv/kool-test';
  late DateTime currentBackPressTime;
  final Completer<InAppWebViewController> _controllerInApp =
  Completer<InAppWebViewController>();
  late InAppWebViewController inAppWebViewController;
  final InAppWebViewSettings _settings = InAppWebViewSettings(
    incognito:false,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    cacheEnabled: true,
    javaScriptEnabled: true,
    useOnDownloadStart: true,
    useOnLoadResource: true,
    allowFileAccessFromFileURLs: true,
    useHybridComposition: true,
    allowContentAccess: true,
    allowFileAccess: true,
    saveFormData: true,
      allowsInlineMediaPlayback: true,
      allowsLinkPreview: true,
      allowsPictureInPictureMediaPlayback: true,
      sharedCookiesEnabled: false,
      applePayAPIEnabled: true
  );


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {

    });

  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: (){
        return checkGoBack();
      },
      child: SafeArea(
        child: LoadingOverlay(
          isLoading: isLoading,
          progressIndicator: const CircularProgressIndicator(),
          color: const Color.fromRGBO(38, 205, 101, 1),
          child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(initialURL)),
              onWebViewCreated: (InAppWebViewController c) async {
                inAppWebViewController = c;
                _controllerInApp.complete(inAppWebViewController);
              },

              // pullToRefreshController: pullToRefreshController,
              initialSettings: _settings,
              onReceivedServerTrustAuthRequest:(_c, challenge) async{
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              }


          ),
        ),
      ),

    );
  }

  Future<bool> checkGoBack() async {
    try{
      if(await inAppWebViewController.canGoBack()){
        inAppWebViewController.goBack();
        return false;
      }
      else{
        return onWillPop();
      }
    }
    catch(e){
      if (kDebugMode) {
        print('Controller Error : $e');
      }
      return false;

    }
  }
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      SnackBar snackBar = const SnackBar(
        backgroundColor: Color.fromRGBO(38, 205, 101, 1),
        content: Text(
          'Lai izietu, vēlreiz nospiediet atpakaļ', style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

