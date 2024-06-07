import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/parser.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
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
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      if(result.contains(ConnectivityResult.none)){
        // inAppWebViewController.loadFile(assetFilePath: 'assets/index.html');
        SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Nav atrasts/vājš internets. Lūdzu, jūsu savienojums.', style: TextStyle(color: Colors.white),),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        inAppWebViewController.loadUrl(urlRequest: URLRequest(url: WebUri('https://app.kool.lv/kool-test/')));

      }
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e.message}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
      if(_connectionStatus.contains(ConnectivityResult.none)){
        // inAppWebViewController.loadFile(assetFilePath: 'assets/index.html');
        SnackBar snackBar = const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Nav atrasts/vājš internets. Lūdzu, jūsu savienojums.', style: TextStyle(color: Colors.white),),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        inAppWebViewController.loadUrl(urlRequest: URLRequest(url: WebUri('https://app.kool.lv/kool-test/')));

      }
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
              shouldOverrideUrlLoading: (c, navAction) async {
                String url = navAction.request.url.toString();
                if(url.contains('tel:')){
                  launchUrl(Uri.parse('tel:+37123456789'));
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('mail:')){
                  launchUrl(Uri.parse('mailto:info@kool.lv'));
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('maps:')){
                  openMapsSheet(context, 'Kool Latvija', 56.973730, 24.163860);
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('facebook:')){
                  launchUrl(Uri.parse('https://www.facebook.com/koollatvija/'));
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('insta:')){
                  launchUrl(Uri.parse('https://www.instagram.com/kool_latvija/'));
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('linkedin:')){
                  launchUrl(Uri.parse('LINKEDIN'));
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('retry:')){
                  c.loadFile(assetFilePath: 'assets/index.html');
                  return NavigationActionPolicy.CANCEL;
                }
                else if(url.contains('geo:')){
                  List<dynamic> list = url.replaceAll('geo:', '').trim().split(',');
                  openMapsSheet(context, parse(list[2]).toString(), double.parse(list[0]), double.parse(list[1]));
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError:(c, request, error){
                if(request.url.toString().contains('geo:')){
                  List<dynamic> list = request.url.toString().replaceAll('geo:', '').trim().split(',');
                  openMapsSheet(context, parse(list[2]).toString(), double.parse(list[0]), double.parse(list[1]));
                  c.goBack();
                }
              },
              onReceivedHttpError:(c, request, error){
                if(request.url.toString().contains('geo:')){
                  List<dynamic> list = request.url.toString().replaceAll('geo:', '').trim().split(',');
                  openMapsSheet(context, parse(list[2]).toString(), double.parse(list[0]), double.parse(list[1]));
                  c.goBack();
                }
              },
              onLoadStop: (c, uri){
                 setState(() {
                   isLoading=false;
                 });
                 if(uri.toString().contains('geo:')){
                   List<dynamic> list = uri.toString().replaceAll('geo:', '').trim().split(',');
                   openMapsSheet(context, parse(list[2]).toString(), double.parse(list[0]), double.parse(list[1]));
                   c.goBack();
                 }
              },
              onReceivedServerTrustAuthRequest:(_c, challenge) async{
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              }


          ),
        ),
      ),

    );
  }
  openMapsSheet(context, String title, double lat, double long) async {
    try {
      final coordinates = Coords(lat, long);
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coordinates,
                        title: title,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
  Future<bool> checkGoBack() async {
    try{
      bool canGoBack = await inAppWebViewController.canGoBack();
      var url = inAppWebViewController.getUrl().toString();
      if(canGoBack && url!='https://app.kool.lv/kool-test/' && url!='https://app.kool.lv/kool-test/#/' && url!='https://app.kool.lv/kool-test/#/home' && url!='https://app.kool.lv/kool-test/#/signin'){
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

